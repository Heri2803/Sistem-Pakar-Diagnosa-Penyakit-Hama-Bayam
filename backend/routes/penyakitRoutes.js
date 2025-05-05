const express = require('express');
const router = express.Router();
const penyakitController = require('../controller/penyakitController');
const uploadPenyakitGambar = require('../middleware/uploadPenyakitGambar');
const multer = require('multer');


/**
 * @swagger
 * tags:
 *   name: Penyakit
 *   description: API untuk mengelola data penyakit
 */

/**
 * @swagger
 * /api/penyakit:
 *   get:
 *     summary: Ambil semua penyakit hama
 *     tags: [Penyakit]
 *     responses:
 *       200:
 *         description: Daftar data penyakit
 */
router.get('/', penyakitController.getAllPenyakit);

/**
 * @swagger
 * /api/penyakit/{id}:
 *   get:
 *     summary: Ambil data penyakit berdasarkan ID
 *     tags: [Penyakit]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID penyakit yang dicari
 *     responses:
 *       200:
 *         description: Data penyakit ditemukan
 *       404:
 *         description: Penyakit tidak ditemukan
 */
router.get('/:id/image', penyakitController.getPenyakitById);

/**
 * @swagger
 * /api/penyakit:
 *   post:
 *     summary: Tambahkan data penyakit baru dengan foto
 *     tags: [Penyakit]
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               nama:
 *                 type: string
 *                 description: Nama penyakit
 *               deskripsi:
 *                 type: string
 *                 description: Deskripsi tentang penyakit
 *               penanganan:
 *                 type: string
 *                 description: Cara penanganan penyakit
 *               foto:
 *                 type: string
 *                 format: binary
 *                 description: Foto penyakit (JPG, JPEG, PNG, GIF)
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
router.post('/', uploadPenyakitGambar.single('foto'), penyakitController.createPenyakit);

/**
 * @swagger
 * /api/penyakit/{id}:
 *   put:
 *     summary: Perbarui data penyakit berdasarkan ID
 *     tags: [Penyakit]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID penyakit yang akan diperbarui
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
 *         description: penyakit berhasil diperbarui
 */
router.put('/:id', uploadPenyakitGambar.single('foto'), penyakitController.updatePenyakit);

/**
 * @swagger
 * /api/penyakit/{id}:
 *   delete:
 *     summary: Hapus data penyakit berdasarkan ID
 *     tags: [Penyakit]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID penyakit yang akan dihapus
 *     responses:
 *       200:
 *         description: Penyakit berhasil dihapus
 */
router.delete('/:id', penyakitController.deletePenyakit);   

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
