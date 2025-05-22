const { Rule_penyakit, Rule_hama, Gejala, Penyakit, Hama, Histori } = require('../models');
const moment = require('moment');

// Helper function to calculate Bayes probability
function calculateBayesProbability(rules, entityType) {
  if (!rules || rules.length === 0) return null;

  const entityData = rules[0][entityType];
  const entityName = entityData.nama;
  const entityId = entityType === 'penyakit' ? rules[0].id_penyakit : rules[0].id_hama;

  // Mencari nilai semesta P(E|Hi) untuk setiap gejala
  let nilai_semesta = 0;
  const gejalaValues = {};

  for (const rule of rules) {
    gejalaValues[rule.id_gejala] = rule.nilai_pakar;
    nilai_semesta += rule.nilai_pakar;
  }

  // Mencari hasil bobot P(Hi) untuk setiap gejala
  const bobotGejala = {};
  for (const [idGejala, nilai] of Object.entries(gejalaValues)) {
    bobotGejala[idGejala] = nilai / nilai_semesta;
  }

  // Hitung probabilitas H tanpa memandang Evidence P(E|Hi) × P(Hi)
  const probTanpaEvidence = {};
  for (const [idGejala, nilai] of Object.entries(gejalaValues)) {
    probTanpaEvidence[idGejala] = nilai * bobotGejala[idGejala];
  }

  // Hitung total untuk digunakan di langkah 4
  let totalProbTanpaEvidence = 0;
  for (const nilai of Object.values(probTanpaEvidence)) {
    totalProbTanpaEvidence += nilai;
  }

  // Hitung probabilitas H dengan memandang Evidence P(Hi|E)
  const probDenganEvidence = {};
  for (const [idGejala, nilai] of Object.entries(probTanpaEvidence)) {
    probDenganEvidence[idGejala] = nilai / totalProbTanpaEvidence;
  }

  // Hitung Nilai Bayes ∑bayes = ∑(P(E|Hi) × P(Hi|E))
  let nilaiBayes = 0;
  const detailBayes = [];

  for (const [idGejala, nilai] of Object.entries(gejalaValues)) {
    const bayes = nilai * probDenganEvidence[idGejala];
    nilaiBayes += bayes;

    detailBayes.push({
      id_gejala: parseInt(idGejala),
      P_E_given_Hi: nilai,
      P_Hi: bobotGejala[idGejala],
      P_E_Hi_x_P_Hi: probTanpaEvidence[idGejala],
      P_Hi_given_E: probDenganEvidence[idGejala],
      bayes_value: bayes
    });
  }

  // Hasil akhir
  const idField = entityType === 'penyakit' ? 'id_penyakit' : 'id_hama';
  return {
    [idField]: entityId,
    nama: entityName,
    nilai_semesta: nilai_semesta,
    detail_perhitungan: detailBayes,
    nilai_bayes: nilaiBayes,
    probabilitas_persen: nilaiBayes * 100,
    jumlah_gejala_cocok: rules.length // Menambahkan jumlah gejala yang cocok
  };
}

// Helper function untuk mendapatkan total gejala yang tersedia untuk entity
async function getTotalGejalaForEntity(entityId, entityType, inputGejala) {
  try {
    let totalGejala = 0;
    
    if (entityType === 'penyakit') {
      const allRules = await Rule_penyakit.findAll({
        where: { id_penyakit: entityId }
      });
      totalGejala = allRules.length;
    } else if (entityType === 'hama') {
      const allRules = await Rule_hama.findAll({
        where: { id_hama: entityId }
      });
      totalGejala = allRules.length;
    }
    
    return totalGejala;
  } catch (error) {
    console.error('Error getting total gejala:', error);
    return 0;
  }
}

// Helper function untuk menyelesaikan ambiguitas
async function resolveAmbiguity(candidates, inputGejala) {
  // Tambahkan informasi total gejala untuk setiap kandidat
  for (let candidate of candidates) {
    const entityType = candidate.type;
    const entityId = entityType === 'penyakit' ? candidate.id_penyakit : candidate.id_hama;
    
    candidate.total_gejala_entity = await getTotalGejalaForEntity(entityId, entityType, inputGejala);
    
    // Hitung persentase kesesuaian gejala
    candidate.persentase_kesesuaian = candidate.total_gejala_entity > 0 
      ? (candidate.jumlah_gejala_cocok / candidate.total_gejala_entity) * 100 
      : 0;
  }

  // Urutkan berdasarkan:
  // 1. Jumlah gejala yang cocok (descending)
  // 2. Persentase kesesuaian (descending)
  // 3. Total gejala entity (ascending - lebih spesifik lebih baik)
  candidates.sort((a, b) => {
    // Prioritas 1: Jumlah gejala cocok
    if (a.jumlah_gejala_cocok !== b.jumlah_gejala_cocok) {
      return b.jumlah_gejala_cocok - a.jumlah_gejala_cocok;
    }
    
    // Prioritas 2: Persentase kesesuaian
    if (Math.abs(a.persentase_kesesuaian - b.persentase_kesesuaian) > 0.01) {
      return b.persentase_kesesuaian - a.persentase_kesesuaian;
    }
    
    // Prioritas 3: Entity dengan total gejala lebih sedikit (lebih spesifik)
    return a.total_gejala_entity - b.total_gejala_entity;
  });

  return candidates[0]; // Kembalikan yang terbaik
}

exports.diagnosa = async (req, res) => {
  const { gejala } = req.body;
  const userId = req.user?.id;
  const tanggal_diagnosa = moment().format('YYYY-MM-DD');

  if (!gejala || !Array.isArray(gejala)) {
    return res.status(400).json({ message: 'Gejala harus berupa array' });
  }

  try {
    // Mengambil semua data yang dibutuhkan sekaligus
    const allGejala = await Gejala.findAll({
      where: { id: gejala }
    });

    // ========== PENYAKIT ==========
    const allPenyakitRules = await Rule_penyakit.findAll({
      where: { id_gejala: gejala },
      include: [{ model: Penyakit, as: 'penyakit' }]
    });

    const uniquePenyakitIds = [...new Set(allPenyakitRules.map(rule => rule.id_penyakit))];
    const hasilPenyakit = [];

    // Hitung untuk setiap penyakit
    for (const idPenyakit of uniquePenyakitIds) {
      const penyakitRules = allPenyakitRules.filter(rule => rule.id_penyakit === idPenyakit);
      const hasil = calculateBayesProbability(penyakitRules, 'penyakit');
      if (hasil) {
        hasilPenyakit.push(hasil);
      }
    }

    // ========== HAMA ==========
    const allHamaRules = await Rule_hama.findAll({
      where: { id_gejala: gejala },
      include: [{ model: Hama, as: 'hama' }]
    });

    const uniqueHamaIds = [...new Set(allHamaRules.map(rule => rule.id_hama))];
    const hasilHama = [];

    // Hitung untuk setiap hama
    for (const idHama of uniqueHamaIds) {
      const hamaRules = allHamaRules.filter(rule => rule.id_hama === idHama);
      const hasil = calculateBayesProbability(hamaRules, 'hama');
      if (hasil) {
        hasilHama.push(hasil);
      }
    }

    // Urutkan hasil berdasarkan probabilitas
    const sortedPenyakit = hasilPenyakit.sort((a, b) => b.probabilitas_persen - a.probabilitas_persen);
    const sortedHama = hasilHama.sort((a, b) => b.probabilitas_persen - a.probabilitas_persen);

    // Gabung hasil dan ambil yang tertinggi (bisa penyakit atau hama)
    const allResults = [
      ...sortedPenyakit.map(p => ({ type: 'penyakit', ...p })),
      ...sortedHama.map(h => ({ type: 'hama', ...h }))
    ].sort((a, b) => b.probabilitas_persen - a.probabilitas_persen);

    // ========== PENANGANAN AMBIGUITAS ==========
    let hasilTertinggi = null;
    let isAmbiguous = false;
    let ambiguityResolution = null;

    if (allResults.length > 0) {
      const nilaiTertinggi = allResults[0].probabilitas_persen;
      
      // Cari semua hasil dengan nilai probabilitas yang sama dengan yang tertinggi
      const kandidatTertinggi = allResults.filter(result => 
        Math.abs(result.probabilitas_persen - nilaiTertinggi) < 0.0001 // Toleransi untuk floating point
      );

      if (kandidatTertinggi.length > 1) {
        // Ada ambiguitas - perlu resolusi
        isAmbiguous = true;
        console.log(`Ditemukan ${kandidatTertinggi.length} kandidat dengan nilai probabilitas sama: ${nilaiTertinggi}%`);
        
        // Lakukan resolusi ambiguitas
        hasilTertinggi = await resolveAmbiguity(kandidatTertinggi, gejala);
        
        ambiguityResolution = {
          total_kandidat: kandidatTertinggi.length,
          metode_resolusi: 'jumlah_gejala_cocok',
          kandidat: kandidatTertinggi.map(k => ({
            type: k.type,
            nama: k.nama,
            probabilitas_persen: k.probabilitas_persen,
            jumlah_gejala_cocok: k.jumlah_gejala_cocok,
            total_gejala_entity: k.total_gejala_entity,
            persentase_kesesuaian: k.persentase_kesesuaian
          })),
          terpilih: {
            type: hasilTertinggi.type,
            nama: hasilTertinggi.nama,
            alasan: `Memiliki ${hasilTertinggi.jumlah_gejala_cocok} gejala cocok dengan kesesuaian ${hasilTertinggi.persentase_kesesuaian?.toFixed(2)}%`
          }
        };
      } else {
        // Tidak ada ambiguitas
        hasilTertinggi = allResults[0];
      }
    }

    // Simpan histori diagnosa jika ada user yang login dan ada hasil diagnosa
    if (!userId) {
      console.error('ID user tidak ditemukan. Histori tidak dapat disimpan.');
    } else {
      const semuaHasil = [...hasilPenyakit, ...hasilHama];

      if (semuaHasil.length > 0 && hasilTertinggi) {
        // Dapatkan waktu saat ini dalam zona waktu Indonesia (GMT+7)
        const now = new Date();
        const jakartaTime = new Date(now.getTime() + (7 * 60 * 60 * 1000)); // GMT+7 (WIB)

        const baseHistoriData = {
          userId: userId, // harus ada
          tanggal_diagnosa: jakartaTime, // Menggunakan waktu real-time Indonesia
          hasil: hasilTertinggi.nilai_bayes, // harus ada, harus tipe FLOAT
        };

        // Tambahkan id_penyakit / id_hama jika ada
        if (hasilTertinggi.id_penyakit) {
          baseHistoriData.id_penyakit = hasilTertinggi.id_penyakit;
        } else if (hasilTertinggi.id_hama) {
          baseHistoriData.id_hama = hasilTertinggi.id_hama;
        }

        try {
          const historiPromises = gejala.map(gejalaId => {
            return Histori.create({
              ...baseHistoriData,
              id_gejala: parseInt(gejalaId)
            });
          });

          await Promise.all(historiPromises);
          console.log(`Histori berhasil disimpan untuk ${gejala.length} gejala dengan waktu: ${jakartaTime.toISOString()}`);
        } catch (error) {
          console.error('Gagal menyimpan histori:', error.message);
        }
      } else {
        console.log('Tidak ada hasil diagnosa untuk disimpan.');
      }
    }

    return res.status(200).json({
      success: true,
      message: 'Berhasil melakukan diagnosa',
      data: {
        penyakit: sortedPenyakit,
        hama: sortedHama,
        gejala_input: gejala.map(id => parseInt(id)),
        hasil_tertinggi: hasilTertinggi,
        is_ambiguous: isAmbiguous,
        ambiguity_resolution: ambiguityResolution
      }
    });

  } catch (error) {
    console.error('Error diagnosa:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal melakukan diagnosa',
      error: error.message
    });
  }
};