const Penyakit = require('../models/penyakit');

// 🔹 Fungsi untuk mendapatkan semua data penyakit
exports.getAllPenyakit = async (req, res) => {
  try {
    const dataPenyakit = await Penyakit.findAll();
    res.status(200).json({ message: 'Data penyakit berhasil diambil', data: dataPenyakit });
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data penyakit', error });
  }
};

// 🔹 Fungsi untuk mendapatkan detail penyakit berdasarkan ID
exports.getPenyakitById = async (req, res) => {
  try {
    const { id } = req.params;
    const penyakit = await Penyakit.findByPk(id);
    if (!penyakit) {
      return res.status(404).json({ message: 'Penyakit tidak ditemukan' });
    }
    res.status(200).json({ message: 'Data penyakit ditemukan', data: penyakit });
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data penyakit', error });
  }
};

// 🔹 Fungsi untuk menambahkan penyakit baru (kode otomatis & kategori default)
exports.createPenyakit = async (req, res) => {
  try {
    const { nama, deskripsi, penanganan } = req.body;

    // Cek kode terakhir
    const lastPenyakit = await Penyakit.findOne({ order: [['id', 'DESC']] });
    let newKode = 'P01'; // Default kode awal
    if (lastPenyakit) {
      const lastNumber = parseInt(lastPenyakit.kode.substring(1)) + 1;
      newKode = `P${lastNumber.toString().padStart(2, '0')}`;
    }

    const newPenyakit = await Penyakit.create({
      kode: newKode,
      nama,
      kategori: 'penyakit', // Default kategori
      deskripsi,
      penanganan,
    });

    res.status(201).json({ message: 'Penyakit berhasil ditambahkan', data: newPenyakit });
  } catch (error) {
    res.status(500).json({ message: 'Gagal menambahkan penyakit', error });
  }
};

// 🔹 Fungsi untuk mengupdate penyakit berdasarkan ID
exports.updatePenyakit = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama, kategori, deskripsi, penanganan } = req.body;

    const penyakit = await Penyakit.findByPk(id);
    if (!penyakit) {
      return res.status(404).json({ message: 'Penyakit tidak ditemukan' });
    }

    await penyakit.update({ nama, kategori, deskripsi, penanganan });

    res.status(200).json({ message: 'Penyakit berhasil diperbarui', data: penyakit });
  } catch (error) {
    res.status(500).json({ message: 'Gagal memperbarui penyakit', error });
  }
};

// 🔹 Fungsi untuk menghapus penyakit berdasarkan ID
exports.deletePenyakit = async (req, res) => {
  try {
    const { id } = req.params;

    const penyakit = await Penyakit.findByPk(id);
    if (!penyakit) {
      return res.status(404).json({ message: 'Penyakit tidak ditemukan' });
    }

    await penyakit.destroy();
    res.status(200).json({ message: 'Penyakit berhasil dihapus' });
  } catch (error) {
    res.status(500).json({ message: 'Gagal menghapus penyakit', error });
  }
};
