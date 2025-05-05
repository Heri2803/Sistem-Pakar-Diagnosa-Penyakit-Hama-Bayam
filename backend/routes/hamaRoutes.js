const express = require('express');
const router = express.Router();
const hamaController = require('../controller/hamaController');
const uploadHamaGambar = require('../middleware/uploadHamaGambar');
const multer = require('multer');

/**
 * @swagger
 * tags:
 *   name: Hama
 *   description: API untuk mengelola data hama
 */

/**
 * @swagger
 * /api/hama:
 *   get:
 *     summary: Ambil semua data hama
 *     tags: [Hama]
 *     responses:
 *       200:
 *         description: Daftar data hama
 */
router.get('/', hamaController.getAllHama);

/**
 * @swagger
 * /api/hama/{id}:
 *   get:
 *     summary: Ambil data hama berdasarkan ID
 *     tags: [Hama]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID hama yang dicari
 *     responses:
 *       200:
 *         description: Data hama ditemukan
 *       404:
 *         description: Hama tidak ditemukan
 */
router.get('/:id/image', hamaController.getHamaById);

/**
 * @swagger
 * /api/hama:
 *   post:
 *     summary: Tambahkan data hama baru dengan foto
 *     tags: [Hama]
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               nama:
 *                 type: string
 *                 description: Nama hama
 *               deskripsi:
 *                 type: string
 *                 description: Deskripsi tentang hama
 *               penanganan:
 *                 type: string
 *                 description: Cara penanganan hama
 *               foto:
 *                 type: string
 *                 format: binary
 *                 description: Foto hama (JPG, JPEG, PNG, GIF)
 *               nilai_pakar:
 *                 type: number
 *                 format: float
 *     responses:
 *       201:
 *         description: Hama berhasil ditambahkan
 *       400:
 *         description: Format file tidak valid atau data tidak lengkap
 *       500:
 *         description: Server error
 */
router.post('/', uploadHamaGambar.single('foto'), hamaController.createHama);

/**
 * @swagger
 * /api/hama/{id}:
 *   put:
 *     summary: Perbarui data hama berdasarkan ID
 *     tags: [Hama]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID hama yang akan diperbarui
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               nama:
 *                 type: string
 *               deskripsi:
 *                 type: string
 *               penanganan:
 *                 type: string
 *               foto:
 *                 type: string
 *                 format: binary
 *               nilai_pakar:
 *                 type: number
 *                 format: float
 *     responses:
 *       200:
 *         description: Hama berhasil diperbarui
 */
router.put('/:id', uploadHamaGambar.single('foto'), hamaController.updateHama);

/**
 * @swagger
 * /api/hama/{id}:
 *   delete:
 *     summary: Hapus data hama berdasarkan ID
 *     tags: [Hama]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID hama yang akan dihapus
 *     responses:
 *       200:
 *         description: Hama berhasil dihapus
 */
router.delete('/:id', hamaController.deleteHama);

// Error handler untuk multer - letakkan SETELAH semua definisi rute
router.use((err, req, res, next) => {
    if (err instanceof multer.MulterError) {
      return res.status(400).json({ 
        success: false, 
        message: 'Error saat upload file', 
        error: err.message 
      });
    } else if (err) {
      return res.status(400).json({ 
        success: false, 
        message: err.message 
      });
    }
    next();
  });

module.exports = router;
