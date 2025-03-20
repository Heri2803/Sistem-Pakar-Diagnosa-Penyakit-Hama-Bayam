const express = require('express');
const router = express.Router();
const hamaController = require('../controller/hamaController');

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
router.get('/:id', hamaController.getHamaById);

/**
 * @swagger
 * /api/hama:
 *   post:
 *     summary: Tambahkan data hama baru
 *     tags: [Hama]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nama:
 *                 type: string
 *               deskripsi:
 *                 type: string
 *               penanganan:
 *                 type: string
 *     responses:
 *       201:
 *         description: Hama berhasil ditambahkan
 */
router.post('/', hamaController.createHama);

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
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nama:
 *                 type: string
 *               kategori:
 *                 type: string
 *               deskripsi:
 *                 type: string
 *               penanganan:
 *                 type: string
 *     responses:
 *       200:
 *         description: Hama berhasil diperbarui
 */
router.put('/:id', hamaController.updateHama);

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

module.exports = router;
