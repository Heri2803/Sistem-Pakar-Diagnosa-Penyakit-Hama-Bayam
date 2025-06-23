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

// Hapus histori berdasarkan userId dan tanggal_diagnosa
exports.deleteHistoriByUserAndDate = async (req, res) => {
  const { user_id, tanggal_diagnosa } = req.body;
  
  // Validasi input
  if (!user_id || user_id === 'null') {
    return res.status(400).json({ message: 'User ID tidak valid' });
  }
  
  if (!tanggal_diagnosa) {
    return res.status(400).json({ message: 'Tanggal diagnosa tidak boleh kosong' });
  }
  
  console.log("Menerima request delete untuk userId:", user_id, "tanggal:", tanggal_diagnosa);
  
  try {
    // Cari histori yang akan dihapus berdasarkan userId dan tanggal_diagnosa
    const histori = await Histori.findAll({
      where: { 
        userId: user_id,
        tanggal_diagnosa: tanggal_diagnosa
      }
    });
    
    if (histori.length === 0) {
      return res.status(404).json({ message: 'Histori tidak ditemukan untuk user dan tanggal yang dimaksud' });
    }
    
    // Hapus semua histori yang sesuai dengan kriteria
    const deletedCount = await Histori.destroy({
      where: { 
        userId: user_id,
        tanggal_diagnosa: tanggal_diagnosa
      }
    });
    
    console.log(`Berhasil menghapus ${deletedCount} record histori untuk userId: ${user_id}, tanggal: ${tanggal_diagnosa}`);
    
    res.status(200).json({ 
      message: 'Histori berhasil dihapus', 
      data: {
        deleted_count: deletedCount,
        user_id: user_id,
        tanggal_diagnosa: tanggal_diagnosa
      }
    });
    
  } catch (error) {
    console.error('Error deleteHistoriByUserAndDate:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

// Hapus histori berdasarkan ID histori (alternative method)
exports.deleteHistoriById = async (req, res) => {
  const { historiId } = req.params;
  
  if (!historiId || historiId === 'null') {
    return res.status(400).json({ message: 'Histori ID tidak valid' });
  }
  
  console.log("Menerima request delete untuk historiId:", historiId);
  
  try {
    // Cari histori berdasarkan ID
    const histori = await Histori.findByPk(historiId);
    
    if (!histori) {
      return res.status(404).json({ message: 'Histori tidak ditemukan' });
    }
    
    // Hapus histori
    await histori.destroy();
    
    console.log(`Berhasil menghapus histori dengan ID: ${historiId}`);
    
    res.status(200).json({ 
      message: 'Histori berhasil dihapus', 
      data: {
        deleted_id: historiId
      }
    });
    
  } catch (error) {
    console.error('Error deleteHistoriById:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

// Hapus semua histori berdasarkan userId (bonus function)
exports.deleteAllHistoriByUserId = async (req, res) => {
  const { userId } = req.params;
  
  if (!userId || userId === 'null') {
    return res.status(400).json({ message: 'User ID tidak valid' });
  }
  
  console.log("Menerima request delete semua histori untuk userId:", userId);
  
  try {
    // Cek apakah ada histori untuk user ini
    const historiCount = await Histori.count({
      where: { userId }
    });
    
    if (historiCount === 0) {
      return res.status(404).json({ message: 'Tidak ada histori untuk user ini' });
    }
    
    // Hapus semua histori untuk user ini
    const deletedCount = await Histori.destroy({
      where: { userId }
    });
    
    console.log(`Berhasil menghapus ${deletedCount} record histori untuk userId: ${userId}`);
    
    res.status(200).json({ 
      message: 'Semua histori user berhasil dihapus', 
      data: {
        deleted_count: deletedCount,
        user_id: userId
      }
    });
    
  } catch (error) {
    console.error('Error deleteAllHistoriByUserId:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

