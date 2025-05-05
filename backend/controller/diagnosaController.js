const { Rule_penyakit, Rule_hama, Gejala, Penyakit, Hama } = require('../models');

exports.diagnosa = async (req, res) => {
  const { gejala } = req.body; // array of id_gejala

  if (!gejala || !Array.isArray(gejala)) {
    return res.status(400).json({ message: 'Gejala harus berupa array' });
  }

  try {
    // ===================== Penyakit =====================
    const allPenyakitRules = await Rule_penyakit.findAll({
      where: {
        id_gejala: gejala,
      },
      include: [
        {
          model: Penyakit,
          as: 'penyakit',
        },
      ],
    });

    const penyakitScores = {};

    allPenyakitRules.forEach(rule => {
      const idPenyakit = rule.id_penyakit;
      const nilaiPakarGejala = rule.nilai_pakar; // P(E|H)
      const nilaiPakarPenyakit = rule.penyakit.nilai_pakar; // P(H)

      if (!penyakitScores[idPenyakit]) {
        // === Menginisialisasi: P(E|H) * P(H) ===
        penyakitScores[idPenyakit] = {
          penyakit: rule.penyakit.nama,
          total: nilaiPakarGejala * nilaiPakarPenyakit, // ← Rumus Bayes awal
        };
      } else {
        // === Mengalikan P(E|H) berikutnya (jika diasumsikan independen) ===
        penyakitScores[idPenyakit].total *= nilaiPakarGejala;
      }
    });

    // ===================== Hama =====================
    const allHamaRules = await Rule_hama.findAll({
      where: {
        id_gejala: gejala,
      },
      include: [
        {
          model: Hama,
          as: 'hama',
        },
      ],
    });

    const hamaScores = {};

    allHamaRules.forEach(rule => {
      const idHama = rule.id_hama;
      const nilaiPakarGejala = rule.nilai_pakar; // P(E|H)
      const nilaiPakarHama = rule.hama.nilai_pakar; // P(H)

      if (!hamaScores[idHama]) {
        // === Menginisialisasi: P(E|H) * P(H) ===
        hamaScores[idHama] = {
          hama: rule.hama.nama,
          total: nilaiPakarGejala * nilaiPakarHama, // ← Rumus Bayes awal
        };
      } else {
        // === Mengalikan P(E|H) berikutnya ===
        hamaScores[idHama].total *= nilaiPakarGejala;
      }
    });

    // ===================== Normalisasi (opsional) =====================
    const totalPenyakit = Object.values(penyakitScores).reduce((acc, cur) => acc + cur.total, 0);
    const totalHama = Object.values(hamaScores).reduce((acc, cur) => acc + cur.total, 0);

    const normalizedPenyakit = Object.values(penyakitScores).map(p => ({
      ...p,
      probabilitas: (p.total / totalPenyakit) || 0, // Probabilitas akhir
    }));

    const normalizedHama = Object.values(hamaScores).map(h => ({
      ...h,
      probabilitas: (h.total / totalHama) || 0,
    }));

    // Sorting
    const sortedPenyakit = normalizedPenyakit.sort((a, b) => b.probabilitas - a.probabilitas);
    const sortedHama = normalizedHama.sort((a, b) => b.probabilitas - a.probabilitas);

    res.json({
      penyakit: sortedPenyakit,
      hama: sortedHama,
    });

  } catch (error) {
    console.error('Error dalam perhitungan Bayes:', error);
    res.status(500).json({ message: 'Terjadi kesalahan dalam proses diagnosa' });
  }
};
