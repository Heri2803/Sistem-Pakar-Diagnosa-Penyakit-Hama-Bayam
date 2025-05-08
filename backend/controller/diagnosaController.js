const { Rule_penyakit, Rule_hama, Gejala, Penyakit, Hama } = require('../models');

exports.diagnosa = async (req, res) => {
  const { gejala } = req.body; // array of id_gejala

  if (!gejala || !Array.isArray(gejala)) {
    return res.status(400).json({ message: 'Gejala harus berupa array' });
  }

  try {
    // Mengambil semua data yang dibutuhkan sekaligus
    const allGejala = await Gejala.findAll({
      where: { id: gejala }
    });

    // ========== HITUNG TOTAL P(E) UNTUK SEMUA GEJALA ==========
    // P(E) seharusnya sama untuk semua penyakit dan hama yang memiliki gejala yang sama
    
    // Object untuk menyimpan P(E) untuk setiap gejala
    const evidenceProbabilities = {};
    
    // Hitung P(E) untuk PENYAKIT
    for (const idGejala of gejala) {
      // Dapatkan semua rule untuk gejala ini di semua penyakit
      const penyakitRulesForGejala = await Rule_penyakit.findAll({
        where: { id_gejala: idGejala },
        include: [{ model: Penyakit, as: 'penyakit' }]
      });
      
      let evidenceProbForGejala = 0;
      
      // Hitung P(E) = Σ [P(E|Hi) * P(Hi)] untuk penyakit
      for (const rule of penyakitRulesForGejala) {
        const pHi = rule.penyakit.nilai_pakar; // P(Hi)
        const pEgivenHi = rule.nilai_pakar;    // P(E|Hi)
        
        evidenceProbForGejala += pEgivenHi * pHi;
      }

      // Dapatkan semua rule untuk gejala ini di semua hama
      const hamaRulesForGejala = await Rule_hama.findAll({
        where: { id_gejala: idGejala },
        include: [{ model: Hama, as: 'hama' }]
      });
      
      // Hitung P(E) = Σ [P(E|Hi) * P(Hi)] untuk hama
      for (const rule of hamaRulesForGejala) {
        const pHi = rule.hama.nilai_pakar; // P(Hi)
        const pEgivenHi = rule.nilai_pakar; // P(E|Hi)
        
        evidenceProbForGejala += pEgivenHi * pHi;
      }
      
      // Simpan P(E) untuk gejala ini
      evidenceProbabilities[idGejala] = evidenceProbForGejala;
    }
    
    // Hitung total P(E) untuk semua gejala yang diinput
    let totalEvidenceProbability = 0;
    for (const idGejala of gejala) {
      totalEvidenceProbability += evidenceProbabilities[idGejala] || 0;
    }
    
    // Pastikan total P(E) tidak nol untuk menghindari division by zero
    if (totalEvidenceProbability === 0) {
      totalEvidenceProbability = 1.0;
    }

    // ========== PENYAKIT ==========
    const allPenyakitRules = await Rule_penyakit.findAll({
      where: { id_gejala: gejala },
      include: [{ model: Penyakit, as: 'penyakit' }]
    });

    // Mendapatkan semua penyakit unik yang memiliki gejala yang dipilih
    const uniquePenyakitIds = [...new Set(allPenyakitRules.map(rule => rule.id_penyakit))];
    
    // Hasil perhitungan untuk setiap penyakit
    const hasilPenyakit = [];

    // Hitung untuk setiap penyakit
    for (const idPenyakit of uniquePenyakitIds) {
      // Filter rules yang berhubungan dengan penyakit ini
      const penyakitRules = allPenyakitRules.filter(rule => rule.id_penyakit === idPenyakit);
      
      if (penyakitRules.length > 0) {
        const dataPenyakit = penyakitRules[0].penyakit;
        const namaPenyakit = dataPenyakit.nama;
        const priorProbability = dataPenyakit.nilai_pakar; // P(H) - prior probability penyakit
        
        // Menghitung P(E|H) untuk setiap gejala
        const evidenceGivenHypothesis = {};
        for (const rule of penyakitRules) {
          evidenceGivenHypothesis[rule.id_gejala] = rule.nilai_pakar; // P(E|H) untuk setiap gejala
        }
        
        // Menghitung P(H|E) = [P(E|H) * P(H)] / P(E) untuk semua gejala
        let posteriorNumerator = priorProbability; // Inisialisasi dengan P(H)
        const evidencesUsed = [];
        
        // Mengalikan dengan nilai P(E|H) untuk setiap gejala yang ada
        for (const idGejala of gejala) {
          if (evidenceGivenHypothesis[idGejala]) {
            posteriorNumerator *= evidenceGivenHypothesis[idGejala];
            evidencesUsed.push({
              id_gejala: parseInt(idGejala),
              P_E_given_H: evidenceGivenHypothesis[idGejala],
              nilai_P_E: evidenceProbabilities[idGejala] || 0
            });
          }
        }
        
        // Posterior probability adalah P(H|E)
        const posteriorProbability = posteriorNumerator / totalEvidenceProbability;
        
        hasilPenyakit.push({
          id_penyakit: idPenyakit,
          nama: namaPenyakit,
          P_H: priorProbability,
          P_E: totalEvidenceProbability,
          evidences: evidencesUsed,
          posterior_numerator: posteriorNumerator,
          posterior_probability: posteriorProbability,
          probabilitas: posteriorProbability
        });
      }
    }
    
    // ========== HAMA ==========
    const allHamaRules = await Rule_hama.findAll({
      where: { id_gejala: gejala },
      include: [{ model: Hama, as: 'hama' }]
    });

    // Mendapatkan semua hama unik yang memiliki gejala yang dipilih
    const uniqueHamaIds = [...new Set(allHamaRules.map(rule => rule.id_hama))];
    
    // Hasil perhitungan untuk setiap hama
    const hasilHama = [];

    // Hitung untuk setiap hama
    for (const idHama of uniqueHamaIds) {
      // Filter rules yang berhubungan dengan hama ini
      const hamaRules = allHamaRules.filter(rule => rule.id_hama === idHama);
      
      if (hamaRules.length > 0) {
        const dataHama = hamaRules[0].hama;
        const namaHama = dataHama.nama;
        const priorProbability = dataHama.nilai_pakar; // P(H) - prior probability hama
        
        // Menghitung P(E|H) untuk setiap gejala
        const evidenceGivenHypothesis = {};
        for (const rule of hamaRules) {
          evidenceGivenHypothesis[rule.id_gejala] = rule.nilai_pakar; // P(E|H) untuk setiap gejala
        }
        
        // Menghitung P(H|E) = [P(E|H) * P(H)] / P(E) untuk semua gejala
        let posteriorNumerator = priorProbability; // Inisialisasi dengan P(H)
        const evidencesUsed = [];
        
        // Mengalikan dengan nilai P(E|H) untuk setiap gejala yang ada
        for (const idGejala of gejala) {
          if (evidenceGivenHypothesis[idGejala]) {
            posteriorNumerator *= evidenceGivenHypothesis[idGejala];
            evidencesUsed.push({
              id_gejala: parseInt(idGejala),
              P_E_given_H: evidenceGivenHypothesis[idGejala],
              nilai_P_E: evidenceProbabilities[idGejala] || 0
            });
          }
        }
        
        // Posterior probability adalah P(H|E)
        const posteriorProbability = posteriorNumerator / totalEvidenceProbability;
        
        hasilHama.push({
          id_hama: idHama,
          nama: namaHama,
          P_H: priorProbability,
          P_E: totalEvidenceProbability,
          evidences: evidencesUsed,
          posterior_numerator: posteriorNumerator,
          posterior_probability: posteriorProbability,
          probabilitas: posteriorProbability
        });
      }
    }
    
    // Urutkan hasil berdasarkan probabilitas
    const sortedPenyakit = hasilPenyakit.sort((a, b) => b.probabilitas - a.probabilitas);
    const sortedHama = hasilHama.sort((a, b) => b.probabilitas - a.probabilitas);

    // Buat ringkasan gejala yang dimasukkan
    const gejalaSummary = await Gejala.findAll({
      where: { id: gejala },
      attributes: ['id', 'kode', 'nama']
    });

    // Kirim hasil perhitungan sebagai respons
    res.json({
      input_gejala: gejalaSummary,
      total_evidence_probability: totalEvidenceProbability,
      evidence_per_gejala: evidenceProbabilities,
      penyakit: sortedPenyakit,
      hama: sortedHama,
      detail_perhitungan: {
        keterangan: "Menggunakan teorema Bayes: P(H|E) = [P(E|H) * P(H)] / P(E)",
        formula: {
          P_H: "Prior probability (nilai pakar untuk penyakit/hama)",
          P_E_given_H: "Likelihood (nilai pakar untuk gejala terhadap penyakit/hama)",
          P_E: "Evidence probability = Σ [P(E|Hi) * P(Hi)] untuk semua hipotesis",
          P_H_given_E: "Posterior probability (hasil akhir)"
        }
      }
    });

  } catch (error) {
    console.error('Error dalam perhitungan Bayes:', error);
    res.status(500).json({ 
      message: 'Terjadi kesalahan dalam proses diagnosa',
      error: error.message 
    });
  }
};