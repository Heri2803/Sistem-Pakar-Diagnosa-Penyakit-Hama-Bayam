const express = require('express');
const router = express.Router();
const authController = require('../controller/authController');

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: API untuk autentikasi pengguna
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Membuat akun baru
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *               
 *             properties:
 *               name:
 *                 type: string
 *                 example: John Doe
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *               alamat:
 *                 type: string
 *                 example: "london inggris"
 *     responses:
 *       201:
 *         description: Akun berhasil dibuat
 *       400:
 *         description: Email sudah digunakan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/register', authController.register);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login ke akun
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *     responses:
 *       200:
 *         description: Login berhasil
 *       401:
 *         description: Password salah
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/login', authController.login);


/**
 * @swagger
 * /api/auth/send-reset-code:
 *   post:
 *     summary: Mengirim kode verifikasi ke email pengguna
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *     responses:
 *       200:
 *         description: Kode verifikasi telah dikirim ke email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Kode verifikasi telah dikirim ke email Anda.
 *                 expiresIn:
 *                   type: string
 *                   example: 10 minutes
 *       400:
 *         description: Email tidak valid
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/send-reset-code', authController.sendResetCodeWithGmail);

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     summary: Reset password menggunakan kode verifikasi
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *               - password
 *             properties:
 *               code:
 *                 type: string
 *                 example: "123456"
 *               password:
 *                 type: string
 *                 example: newpassword123
 *     responses:
 *       200:
 *         description: Password berhasil direset
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Password berhasil direset
 *                 success:
 *                   type: boolean
 *                   example: true
 *       400:
 *         description: Kode tidak valid atau password tidak memenuhi syarat
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/reset-password', authController.resetPasswordWithCode);

module.exports = router;
