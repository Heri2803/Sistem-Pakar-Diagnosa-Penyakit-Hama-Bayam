const express = require('express');
const router = express.Router();
const ruleController = require('../controller/rulesHamaController');

/**
 * @swagger
 * tags:
 *   name: Rules_hama
 *   description: API untuk mengelola aturan (rules)
 */

/**
 * @swagger
 * /api/rules_hama:
 *   post:
 *     summary: Membuat aturan baru
 *     tags: [Rules_hama]
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
router.post('/', ruleController.createRuleHama);

/**
 * @swagger
 * /api/rules_hama:
 *   get:
 *     summary: Menampilkan semua aturan
 *     tags: [Rules_hama]
 *     responses:
 *       200:
 *         description: Daftar rules berhasil diambil
 *       500:
 *         description: Terjadi kesalahan server
 */
router.get('/', ruleController.getRulesHama);

/**
 * @swagger
 * /api/rules_hama/{id}:
 *   put:
 *     summary: Memperbarui aturan berdasarkan ID
 *     tags: [Rules_hama]
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
router.put('/:id', ruleController.updateRuleHama);

/**
 * @swagger
 * /api/rules_hama/{id}:
 *   delete:
 *     summary: Menghapus aturan berdasarkan ID
 *     tags: [Rules_hama]
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
router.delete('/:id', ruleController.deleteRuleHama);

module.exports = router;
