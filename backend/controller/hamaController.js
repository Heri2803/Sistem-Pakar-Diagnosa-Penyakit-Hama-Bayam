const {Hama} = require('../models');

// 🔹 Fungsi untuk mendapatkan semua data hama
exports.getAllHama = async (req, res) => {
  try {
    const dataHama = await Hama.findAll({
      attributes: ['id', 'nama' , 'deskripsi' , 'penanganan']
    });
    res.status(200).json({ message: 'Data hama berhasil diambil', data: dataHama });
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data hama', error });
  }
};

// 🔹 Fungsi untuk mendapatkan detail hama berdasarkan ID
exports.getHamaById = async (req, res) => {
  try {
    const { id } = req.params;
    const hama = await Hama.findByPk(id);
    if (!hama) {
      return res.status(404).json({ message: 'Hama tidak ditemukan' });
    }
    res.status(200).json({ message: 'Data hama ditemukan', data: hama });
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data hama', error });
  }
};

// Pastikan sudah import 'Hama' model dan multer middleware sebelumnya

exports.createHama = async (req, res) => {
  try {
    const { nama, deskripsi, penanganan } = req.body;
    const file = req.file; 

    // Cek kode terakhir
    const lastHama = await Hama.findOne({ order: [['id', 'DESC']] });
    let newKode = 'H01'; // Default kode awal
    if (lastHama) {
      const lastNumber = parseInt(lastHama.kode.substring(1)) + 1;
      newKode = `H${lastNumber.toString().padStart(2, '0')}`;
    }

    // Cek kalau ada file yang diupload
    let fotoPath = '';
    if (file) {
      fotoPath = file.filename; 
    }

    const newHama = await Hama.create({
      kode: newKode,
      nama,
      kategori: 'hama', // Default kategori
      deskripsi,
      penanganan,
      foto: fotoPath, // ⬅️ Masukkan nama file ke database
    });

    res.status(201).json({ message: 'Hama berhasil ditambahkan', data: newHama });
  } catch (error) {
    res.status(500).json({ message: 'Gagal menambahkan hama', error: error.message });
  }
};


// 🔹 Fungsi untuk mengupdate hama berdasarkan ID
exports.updateHama = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama, kategori, deskripsi, penanganan } = req.body;

    const hama = await Hama.findByPk(id);
    if (!hama) {
      return res.status(404).json({ message: 'Hama tidak ditemukan' });
    }

    await hama.update({ nama, kategori, deskripsi, penanganan });

    res.status(200).json({ message: 'Hama berhasil diperbarui', data: hama });
  } catch (error) {
    res.status(500).json({ message: 'Gagal memperbarui hama', error });
  }
};

// 🔹 Fungsi untuk menghapus hama berdasarkan ID
exports.deleteHama = async (req, res) => {
  try {
    const { id } = req.params;

    const hama = await Hama.findByPk(id);
    if (!hama) {
      return res.status(404).json({ message: 'Hama tidak ditemukan' });
    }

    await hama.destroy();
    res.status(200).json({ message: 'Hama berhasil dihapus' });
  } catch (error) {
    res.status(500).json({ message: 'Gagal menghapus hama', error });
  }
};
