const express = require('express');
const router = express.Router();
const ruleController = require('../controller/rulesController');

/**
 * @swagger
 * tags:
 *   name: Rules
 *   description: API untuk mengelola aturan (rules)
 */

/**
 * @swagger
 * /api/rules:
 *   post:
 *     summary: Membuat aturan baru
 *     tags: [Rules]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id_gejala
 *               - nilai_pakar
 *             properties:
 *               id_gejala:
 *                 type: integer
 *               id_penyakit:
 *                 type: integer
 *               id_hama:
 *                 type: integer
 *               nilai_pakar:
 *                 type: number
 *                 format: float
 *     responses:
 *       201:
 *         description: Rule berhasil dibuat
 *       400:
 *         description: Data tidak lengkap
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/', ruleController.createRule);

/**
 * @swagger
 * /api/rules:
 *   get:
 *     summary: Menampilkan semua aturan
 *     tags: [Rules]
 *     responses:
 *       200:
 *         description: Daftar rules berhasil diambil
 *       500:
 *         description: Terjadi kesalahan server
 */
router.get('/', ruleController.getRules);

/**
 * @swagger
 * /api/rules/{id}:
 *   put:
 *     summary: Memperbarui aturan berdasarkan ID
 *     tags: [Rules]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID rule yang ingin diperbarui
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               id_gejala:
 *                 type: integer
 *               id_penyakit:
 *                 type: integer
 *               id_hama:
 *                 type: integer
 *               nilai_pakar:
 *                 type: number
 *                 format: float
 *     responses:
 *       200:
 *         description: Rule berhasil diperbarui
 *       404:
 *         description: Rule tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.put('/:id', ruleController.updateRule);

/**
 * @swagger
 * /api/rules/{id}:
 *   delete:
 *     summary: Menghapus aturan berdasarkan ID
 *     tags: [Rules]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID rule yang ingin dihapus
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Rule berhasil dihapus
 *       404:
 *         description: Rule tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.delete('/:id', ruleController.deleteRule);

module.exports = router;
