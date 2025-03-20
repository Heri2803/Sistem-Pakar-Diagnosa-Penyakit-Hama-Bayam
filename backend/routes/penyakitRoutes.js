const express = require('express');
const router = express.Router();
const penyakitController = require('../controller/penyakitController');

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
router.get('/:id', penyakitController.getPenyakitById);

/**
 * @swagger
 * /api/penyakit:
 *   post:
 *     summary: Tambahkan data penyakit baru
 *     tags: [Penyakit]
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
router.post('/', penyakitController.createPenyakit);

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
 *         description: penyakit berhasil diperbarui
 */
router.put('/:id', penyakitController.updatePenyakit);

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

module.exports = router;
