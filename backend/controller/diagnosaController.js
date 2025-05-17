const { Rule_penyakit, Rule_hama, Gejala, Penyakit, Hama, Histori } = require('../models');
const moment = require('moment');

// Helper function to calculate Bayes probability
function calculateBayesProbability(rules, entityType) {
  if (!rules || rules.length === 0) return null;
  
  const entityData = rules[0][entityType];
  const entityName = entityData.nama;
  const entityId = entityType === 'penyakit' ? rules[0].id_penyakit : rules[0].id_hama;
  
  // LANGKAH 1: Mencari nilai semesta P(E|Hi) untuk setiap gejala
  let nilai_semesta = 0;
  const gejalaValues = {};
  
  for (const rule of rules) {
    gejalaValues[rule.id_gejala] = rule.nilai_pakar;
    nilai_semesta += rule.nilai_pakar;
  }
  
  // LANGKAH 2: Mencari hasil bobot P(Hi) untuk setiap gejala
  const bobotGejala = {};
  for (const [idGejala, nilai] of Object.entries(gejalaValues)) {
    bobotGejala[idGejala] = nilai / nilai_semesta;
  }
  
  // LANGKAH 3: Hitung probabilitas H tanpa memandang Evidence P(E|Hi) × P(Hi)
  const probTanpaEvidence = {};
  for (const [idGejala, nilai] of Object.entries(gejalaValues)) {
    probTanpaEvidence[idGejala] = nilai * bobotGejala[idGejala];
  }
  
  // Hitung total untuk digunakan di langkah 4
  let totalProbTanpaEvidence = 0;
  for (const nilai of Object.values(probTanpaEvidence)) {
    totalProbTanpaEvidence += nilai;
  }
  
  // LANGKAH 4: Hitung probabilitas H dengan memandang Evidence P(Hi|E)
  const probDenganEvidence = {};
  for (const [idGejala, nilai] of Object.entries(probTanpaEvidence)) {
    probDenganEvidence[idGejala] = nilai / totalProbTanpaEvidence;
  }
  
  // LANGKAH 5: Hitung Nilai Bayes ∑bayes = ∑(P(E|Hi) × P(Hi|E))
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
    probabilitas_persen: nilaiBayes * 100
  };
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
    
    // Simpan histori diagnosa jika ada user yang login dan ada hasil diagnosa
    if (!userId) {
      console.error('ID user tidak ditemukan. Histori tidak dapat disimpan.');
    } else {
      const semuaHasil = [...hasilPenyakit, ...hasilHama];
    
      if (semuaHasil.length > 0) {
        const hasilTerbesar = semuaHasil.reduce((max, current) => {
          return current.probabilitas_persen > max.probabilitas_persen ? current : max;
        });
    
        const baseHistoriData = {
          userId: userId, // harus ada
          tanggal_diagnosa: tanggal_diagnosa, // harus ada
          hasil: hasilTerbesar.nilai_bayes, // harus ada, harus tipe FLOAT
        };
        
        // Tambahkan id_penyakit / id_hama jika ada
        if (hasilTerbesar.id_penyakit) {
          baseHistoriData.id_penyakit = hasilTerbesar.id_penyakit;
        } else if (hasilTerbesar.id_hama) {
          baseHistoriData.id_hama = hasilTerbesar.id_hama;
        }        
    
        try {
          const historiPromises = gejala.map(gejalaId => {
            return Histori.create({
              ...baseHistoriData,
              id_gejala: parseInt(gejalaId)
            });
          });
          
          await Promise.all(historiPromises);
          console.log(`Histori berhasil disimpan untuk ${gejala.length} gejala.`);
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
        hasil_tertinggi: allResults.length > 0 ? allResults[0] : null
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