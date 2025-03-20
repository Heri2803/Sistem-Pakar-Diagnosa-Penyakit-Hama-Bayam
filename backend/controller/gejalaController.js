const Gejala = require('../models/gejala');

// 🔹 Menampilkan semua data gejala
exports.getAllGejala = async (req, res) => {
  try {
    const gejala = await Gejala.findAll();
    res.status(200).json(gejala);
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan', error });
  }
};

// 🔹 Menampilkan satu gejala berdasarkan ID
exports.getGejalaById = async (req, res) => {
  try {
    const gejala = await Gejala.findByPk(req.params.id);
    if (!gejala) {
      return res.status(404).json({ message: 'Gejala tidak ditemukan' });
    }
    res.status(200).json(gejala);
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan', error });
  }
};

// 🔹 Menambahkan gejala baru dengan kode otomatis
exports.createGejala = async (req, res) => {
    try {
      const { nama } = req.body;
      
      if (!nama) {
        return res.status(400).json({ message: 'Nama gejala wajib diisi' });
      }
  
      // Cari kode terakhir di database
      const lastGejala = await Gejala.findOne({
        order: [['id', 'DESC']]
      });
  
      // Generate kode baru berdasarkan kode terakhir
      let newKode = 'G01';
      if (lastGejala && lastGejala.kode) {
        const lastNumber = parseInt(lastGejala.kode.substring(1)); // Ambil angka setelah 'G'
        const nextNumber = lastNumber + 1;
        newKode = `G${nextNumber.toString().padStart(2, '0')}`; // Format G01, G02, dst.
      }
  
      // Buat data baru
      const newGejala = await Gejala.create({ kode: newKode, nama });
  
      res.status(201).json({ message: 'Gejala berhasil ditambahkan', data: newGejala });
    } catch (error) {
      res.status(500).json({ message: 'Gagal menambahkan gejala', error: error.message });
    }
  };

// 🔹 Mengupdate gejala berdasarkan ID
exports.updateGejala = async (req, res) => {
  try {
    const { kode, nama } = req.body;
    const gejala = await Gejala.findByPk(req.params.id);
    
    if (!gejala) {
      return res.status(404).json({ message: 'Gejala tidak ditemukan' });
    }

    await gejala.update({ kode, nama });
    res.status(200).json({ message: 'Gejala berhasil diperbarui', data: gejala });
  } catch (error) {
    res.status(500).json({ message: 'Gagal memperbarui gejala', error });
  }
};

// 🔹 Menghapus gejala berdasarkan ID
exports.deleteGejala = async (req, res) => {
  try {
    const gejala = await Gejala.findByPk(req.params.id);

    if (!gejala) {
      return res.status(404).json({ message: 'Gejala tidak ditemukan' });
    }

    await gejala.destroy();
    res.status(200).json({ message: 'Gejala berhasil dihapus' });
  } catch (error) {
    res.status(500).json({ message: 'Gagal menghapus gejala', error });
  }
};
