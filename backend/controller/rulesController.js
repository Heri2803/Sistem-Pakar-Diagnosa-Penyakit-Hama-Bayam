const { Rule, gejala, penyakit, hama } = require('../models');

// 🔥 Buat aturan baru
exports.createRule = async (req, res) => {
  try {
    const { id_gejala, id_penyakit, id_hama, nilai_pakar } = req.body;

    // Validasi minimal
    if (!id_gejala || (!id_penyakit && !id_hama) || !nilai_pakar) {
      return res.status(400).json({ message: 'Data tidak lengkap' });
    }

    const newRule = await Rule.create({
      id_gejala,
      id_penyakit,
      id_hama,
      nilai_pakar
    });

    res.status(201).json({ message: 'Rule berhasil dibuat', data: newRule });
  } catch (error) {
    console.error('Error createRule:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

// 🔥 Ambil semua aturan
exports.getRules = async (req, res) => {
  try {
    const rules = await Rule.findAll();

    res.status(200).json({ message: 'Daftar Rules', data: rules });
  } catch (error) {
    console.error('Error getRules:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

// 🔥 Update aturan
exports.updateRule = async (req, res) => {
  try {
    const { id } = req.params;
    const { id_gejala, id_penyakit, id_hama, nilai_pakar } = req.body;

    const rule = await Rule.findByPk(id);
    if (!rule) {
      return res.status(404).json({ message: 'Rule tidak ditemukan' });
    }

    await rule.update({
      id_gejala,
      id_penyakit,
      id_hama,
      nilai_pakar
    });

    res.status(200).json({ message: 'Rule berhasil diperbarui', data: rule });
  } catch (error) {
    console.error('Error updateRule:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

// 🔥 Hapus aturan
exports.deleteRule = async (req, res) => {
  try {
    const { id } = req.params;

    const rule = await Rule.findByPk(id);
    if (!rule) {
      return res.status(404).json({ message: 'Rule tidak ditemukan' });
    }

    await rule.destroy();

    res.status(200).json({ message: 'Rule berhasil dihapus' });
  } catch (error) {
    console.error('Error deleteRule:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};
