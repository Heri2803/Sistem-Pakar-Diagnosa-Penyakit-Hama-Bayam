const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Path folder penyimpanan gambar
const uploadPath = path.join(__dirname, '../image_penyakit');

// Pastikan folder sudah ada, jika belum maka buat
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
}

// Konfigurasi storage untuk multer
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    cb(null, uploadPath);
  },
  filename: function(req, file, cb) {
    // Format nama file: hama-timestamp.extension
    const timestamp = new Date().getTime();
    const ext = path.extname(file.originalname);
    cb(null, `penyakit-${timestamp}${ext}`);
  }
});

// Filter untuk memastikan hanya file gambar yang diupload
const fileFilter = (req, file, cb) => {
  // Izinkan hanya format gambar yang umum
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
  
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Format file tidak didukung! Hanya file JPG, JPEG, PNG, dan GIF yang diizinkan.'), false);
  }
};

// Inisialisasi multer dengan konfigurasi
const uploadHamaGambar = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // Batasi ukuran file maksimal 5MB
  }
});

module.exports = uploadHamaGambar;