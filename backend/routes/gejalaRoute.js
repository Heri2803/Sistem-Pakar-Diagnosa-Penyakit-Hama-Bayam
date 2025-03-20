const express = require('express');
const router = express.Router();
const gejalaController = require('../controller/gejalaController');

/**
 * @swagger
 * tags:
 *   name: Gejala
 *   description: Manajemen Gejala Penyakit
 */

/**
 * @swagger
 * /api/gejala:
 *   get:
 *     summary: Mendapatkan semua gejala
 *     tags: [Gejala]
 *     responses:
 *       200:
 *         description: Berhasil mengambil data
 */
router.get('/', gejalaController.getAllGejala);

/**
 * @swagger
 * /api/gejala/{id}:
 *   get:
 *     summary: Mendapatkan gejala berdasarkan ID
 *     tags: [Gejala]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Berhasil mengambil data
 *       404:
 *         description: Gejala tidak ditemukan
 */
router.get('/:id', gejalaController.getGejalaById);

/**
 * @swagger
 * /api/gejala:
 *   post:
 *     summary: Menambahkan gejala baru
 *     tags: [Gejala]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               kode:
 *                 type: string
 *               nama:
 *                 type: string
 *     responses:
 *       201:
 *         description: Gejala berhasil ditambahkan
 *       500:
 *         description: Gagal menambahkan gejala
 */
router.post('/', gejalaController.createGejala);

/**
 * @swagger
 * /api/gejala/{id}:
 *   put:
 *     summary: Memperbarui gejala berdasarkan ID
 *     tags: [Gejala]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               kode:
 *                 type: string
 *               nama:
 *                 type: string
 *     responses:
 *       200:
 *         description: Gejala berhasil diperbarui
 *       404:
 *         description: Gejala tidak ditemukan
 */
router.put('/:id', gejalaController.updateGejala);

/**
 * @swagger
 * /api/gejala/{id}:
 *   delete:
 *     summary: Menghapus gejala berdasarkan ID
 *     tags: [Gejala]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Gejala berhasil dihapus
 *       404:
 *         description: Gejala tidak ditemukan
 */
router.delete('/:id', gejalaController.deleteGejala);

module.exports = router;
