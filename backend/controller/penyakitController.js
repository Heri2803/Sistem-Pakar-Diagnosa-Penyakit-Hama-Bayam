const {Penyakit} = require('../models');
const path = require('path'); 
const fs = require('fs');

// 🔹 Fungsi untuk mendapatkan semua data penyakit
exports.getAllPenyakit = async (req, res) => {
  try {
    const dataPenyakit = await Penyakit.findAll({
      attributes: ['id', 'nama' , 'deskripsi' , 'penanganan' , 'foto']
    });
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
  
      if (!penyakit || !penyakit.foto) {
        return res.status(404).json({ message: 'Gambar tidak ditemukan' });
      }
  
      console.log('Nama file gambar dari database:', penyakit.foto);
  
      const imagePath = path.resolve(__dirname, '..', 'image_penyakit', penyakit.foto);
      console.log('Path absolut file gambar:', imagePath);
  
      if (!fs.existsSync(imagePath)) {
        return res.status(404).json({ message: 'File gambar tidak ditemukan di path tersebut' });
      }
  
      const ext = path.extname(penyakit.foto).toLowerCase();
      let contentType = 'image/jpeg';
  
      if (ext === '.png') contentType = 'image/png';
      else if (ext === '.gif') contentType = 'image/gif';
  
      res.setHeader('Content-Type', contentType);
      res.sendFile(imagePath);
    } catch (error) {
      console.error('Error saat mengambil gambar:', error.stack);
      res.status(500).json({ message: 'Gagal mengambil gambar', error: error.message });
    }
};

// 🔹 Fungsi untuk menambahkan penyakit baru (kode otomatis & kategori default)
exports.createPenyakit = async (req, res) => {
  try {
    const { nama, deskripsi, penanganan } = req.body;
    const file = req.file; 

    // Cek kode terakhir
    const lastPenyakit = await Penyakit.findOne({ order: [['id', 'DESC']] });
    let newKode = 'P01'; // Default kode awal
    if (lastPenyakit) {
      const lastNumber = parseInt(lastPenyakit.kode.substring(1)) + 1;
      newKode = `P${lastNumber.toString().padStart(2, '0')}`;
    }

    // Cek kalau ada file yang diupload
    let fotoPath = '';
    if (file) {
      fotoPath = file.filename; 
    }

    const newPenyakit = await Penyakit.create({
      kode: newKode,
      nama,
      kategori: 'penyakit', // Default kategori
      deskripsi,
      penanganan,
      foto: fotoPath,
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

    // Ambil nama file jika ada file foto yang diunggah
    let foto = penyakit.foto; // default: tetap gunakan yang lama
    if (req.file) {
      foto = req.file.filename;
    }

    await penyakit.update({ nama, kategori, deskripsi, penanganan, foto });

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
