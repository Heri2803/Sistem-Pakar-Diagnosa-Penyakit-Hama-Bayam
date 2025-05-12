const { Histori, Gejala, Penyakit, Hama } = require('../models');

//  Ambil semua histori
exports.getAllHistori = async (req, res) => {
    try {
      const histori = await Histori.findAll();
  
      res.status(200).json({ message: 'Data Histori', data: histori });
    } catch (error) {
      console.error('Error getHistori:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
  };

// Ambil histori berdasarkan ID user
exports.getHistoriByUserId = async (req, res) => {
    const { userId } = req.params; // Ambil ID user dari parameter URL          
    
    if (!userId || userId === 'null') {
        return res.status(400).json({ message: 'User ID tidak valid' });
      }
    
      console.log("Menerima request untuk userId:", userId);
  try {
    const histori = await Histori.findAll({
      where: { userId }, // Filter berdasarkan ID user
      include: [
        {
          model: Gejala,
          as: 'gejala',
          attributes: ['id', 'kode', 'nama']
        },
        {
          model: Penyakit,
          as: 'penyakit',
          attributes: ['id', 'nama']
        },
        {
          model: Hama,
          as: 'hama',
          attributes: ['id', 'nama']
        }
      ],
      order: [['tanggal_diagnosa', 'DESC']] // Urutkan berdasarkan tanggal diagnosa terbaru
    });

    if (histori.length === 0) {
      return res.status(404).json({ message: 'Tidak ada histori untuk user ini' });
    }

    res.status(200).json({ message: 'Data Histori User', data: histori });
  } catch (error) {
    console.error('Error getHistoriByUserId:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

