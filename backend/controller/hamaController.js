const {Hama} = require('../models');
const path = require('path'); 
const fs = require('fs');

// 🔹 Fungsi untuk mendapatkan semua data hama
exports.getAllHama = async (req, res) => {
  try {
    const dataHama = await Hama.findAll({
      attributes: ['id', 'nama' , 'deskripsi' , 'penanganan', 'foto', 'kode', 'nilai_pakar']
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

    if (!hama || !hama.foto) {
      return res.status(404).json({ message: 'Gambar tidak ditemukan' });
    }

    console.log('Nama file gambar dari database:', hama.foto);

    // Naik 1 level dari 'controller' ke 'backend'
    const imagePath = path.resolve(__dirname, '..', 'image_hama', hama.foto);
    console.log('Path absolut file gambar:', imagePath);

    if (!fs.existsSync(imagePath)) {
      return res.status(404).json({ message: 'File gambar tidak ditemukan di path tersebut' });
    }

    const ext = path.extname(hama.foto).toLowerCase();
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

// Pastikan sudah import 'Hama' model dan multer middleware sebelumnya
exports.createHama = async (req, res) => {
  try {
    const { nama, deskripsi, penanganan, nilai_pakar } = req.body;
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
      kategori: 'hama', 
      deskripsi,
      penanganan,
      foto: fotoPath, 
      nilai_pakar
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
    const { nama, kategori, deskripsi, penanganan, nilai_pakar, } = req.body;

    const hama = await Hama.findByPk(id);
    if (!hama) {
      return res.status(404).json({ message: 'Hama tidak ditemukan' });
    }

     // Ambil nama file jika ada file foto yang diunggah
     let foto = hama.foto; // default: tetap gunakan yang lama
     if (req.file) {
       foto = req.file.filename;
     }

    await hama.update({ nama, kategori, deskripsi, penanganan, foto, nilai_pakar });

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
