const jwt = require('jsonwebtoken');
const argon2 = require('argon2');
const randomstring = require('randomstring');
const  {User}  = require('../models'); // Pastikan sesuai dengan struktur project
require('dotenv').config();
const nodemailer = require('nodemailer');
const sgMail = require('@sendgrid/mail');

// Fungsi untuk membuat token JWT
const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, email: user.email, role: user.role }, // id bukan _id untuk Sequelize
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
    );
};

// Menambahkan user baru dengan hashing Argon2
exports.register = async (req, res) => {
    try {
      const { name, email, password, alamat,  role } = req.body;
  
      // Cek apakah email sudah terdaftar
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) return res.status(400).json({ message: 'Email already exists' });
  
      // Hash password menggunakan Argon2
      const hashedPassword = await argon2.hash(password);
  
      const newUser = await User.create({
        name,
        email,
        password: hashedPassword,
        alamat,
        role: 'user'
      });
  
      res.status(201).json({ message: 'User created successfully', user: newUser });
    } catch (error) {
      res.status(500).json({ message: 'Error creating user', error });
    }
  };

 // Inisialisasi global variables di awal file
const activeSessions = {}; // { userId: true }
const sessionTimeouts = {}; // { userId: timeoutId }

// Login
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // 🔹 Cek apakah user dengan email tersebut ada
        const user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(401).json({ message: "Email atau password salah" });
        }

        // 🔹 Cek apakah user sudah login di device lain
        if (activeSessions[user.id]) {
            return res.status(403).json({ 
                message: "Akun ini sedang digunakan di perangkat lain.",
                debug: `User ${user.id} masih dalam sesi aktif`
            });
        }

        // 🔹 Verifikasi password
        const isPasswordValid = await argon2.verify(user.password, password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: "Email atau password salah" });
        }

        // 🔹 Buat token JWT
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role }, 
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
        );

        // 🔹 Tandai user sedang login (aktif)
        activeSessions[user.id] = {
            loginTime: new Date(),
            email: user.email
        };

        // 🔹 Bersihkan timeout lama jika ada
        if (sessionTimeouts[user.id]) {
            clearTimeout(sessionTimeouts[user.id]);
            delete sessionTimeouts[user.id];
        }

        // 🔹 Atur timer logout otomatis setelah 5 menit
        sessionTimeouts[user.id] = setTimeout(() => {
            console.log(`User ID ${user.id} (${user.email}) otomatis logout karena timeout`);
            delete activeSessions[user.id];
            delete sessionTimeouts[user.id];
        }, 12 * 60 * 60 * 1000); // 5 menit

        console.log("Login berhasil - User ID:", user.id, "Email:", user.email);
        console.log("Active sessions:", Object.keys(activeSessions));

        // 🔹 Kirim response
        res.status(200).json({
            message: "Login berhasil",
            token,
            role: user.role,
            userId: user.id
        });

    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ message: "Terjadi kesalahan", error: error.message });
    }
};

// Logout (Versi yang lebih robust)
exports.logout = async (req, res) => {
    try {
        // Coba ambil userId dari berbagai sumber
        let userId = req.user?.id;
        
        // Jika tidak ada dari middleware, coba ambil dari body atau query
        if (!userId) {
            userId = req.body?.userId || req.query?.userId;
        }
        
        // Jika masih tidak ada, coba decode token manual
        if (!userId && req.headers.authorization) {
            try {
                const token = req.headers.authorization.split(' ')[1];
                const decoded = jwt.verify(token, process.env.JWT_SECRET);
                userId = decoded.id;
            } catch (tokenError) {
                console.log("Token decode error:", tokenError.message);
            }
        }

        console.log("Logout attempt - User ID:", userId);
        console.log("Active sessions before logout:", Object.keys(activeSessions));

        if (userId && activeSessions[userId]) {
            // Hapus sesi aktif
            delete activeSessions[userId];
            
            // Bersihkan timeout
            if (sessionTimeouts[userId]) {
                clearTimeout(sessionTimeouts[userId]);
                delete sessionTimeouts[userId];
            }
            
            console.log("Logout berhasil - User ID:", userId);
            console.log("Active sessions after logout:", Object.keys(activeSessions));
            
            return res.status(200).json({ 
                message: "Logout berhasil",
                userId: userId
            });
        }
        
        console.log("Logout gagal - Tidak ada sesi aktif untuk User ID:", userId);
        res.status(400).json({ 
            message: "Tidak ada sesi login aktif",
            userId: userId,
            activeSessions: Object.keys(activeSessions)
        });
        
    } catch (error) {
        console.error("Logout error:", error);
        res.status(500).json({ message: "Terjadi kesalahan saat logout", error: error.message });
    }
};

// Tambahkan endpoint untuk debugging (opsional - hapus di production)
exports.debugSessions = (req, res) => {
    res.json({
        activeSessions: activeSessions,
        sessionTimeouts: Object.keys(sessionTimeouts),
        message: "Debug info - hapus endpoint ini di production"
    });
};

// Force logout (untuk admin atau debugging)
exports.forceLogout = (req, res) => {
    const { userId } = req.body;
    
    if (userId && activeSessions[userId]) {
        delete activeSessions[userId];
        if (sessionTimeouts[userId]) {
            clearTimeout(sessionTimeouts[userId]);
            delete sessionTimeouts[userId];
        }
        return res.json({ message: `User ${userId} berhasil di-force logout` });
    }
    
    res.status(404).json({ message: "User tidak ditemukan dalam sesi aktif" });
};

// Clear semua sessions (untuk debugging)
exports.clearAllSessions = (req, res) => {
    const sessionCount = Object.keys(activeSessions).length;
    
    // Bersihkan semua timeout
    Object.keys(sessionTimeouts).forEach(userId => {
        clearTimeout(sessionTimeouts[userId]);
        delete sessionTimeouts[userId];
    });
    
    // Bersihkan semua active sessions
    Object.keys(activeSessions).forEach(userId => {
        delete activeSessions[userId];
    });
    
    console.log(`Cleared ${sessionCount} active sessions`);
    
    res.json({
        message: "Semua sesi aktif berhasil dibersihkan",
        clearedSessions: sessionCount
    });
};


// Buat transporter Nodemailer dengan Gmail
const createGmailTransporter = () => {
    return nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_FROM, // sibayam52@gmail.com dari .env yang sudah ada
        pass: process.env.EMAIL_PASS,  // Gunakan App Password, bukan password biasa!
      },
      // Pool koneksi untuk menghindari rate limiting
      pool: true,
      maxConnections: 3,
      maxMessages: 50,
      rateDelta: 1500,
      rateLimit: 3
    });
  };
  
  exports.sendResetCodeWithGmail = async (req, res) => {
    const { email } = req.body;
  
    try {
      // Validasi email
      if (!email || !email.includes('@')) {
        return res.status(400).json({ message: 'Email tidak valid' });
      }
  
      const user = await User.findOne({ where: { email } });
      if (!user) return res.status(404).json({ message: 'User tidak ditemukan' });
  
      // Generate 6 digit random code
      const code = Math.floor(100000 + Math.random() * 900000).toString();
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

// Konversi ke waktu Indonesia (GMT+7)
const expiresAtWIB = new Date(expiresAt.getTime() + 7 * 60 * 60 * 1000);

// Format manual jadi ISO-like (tanpa Z karena bukan UTC)
const isoWIB = expiresAtWIB.toISOString().replace( '+07:00');

      await user.update({
        resetToken: code,
        resetTokenExpiry: isoWIB,
      });
  
      // Nama aplikasi yang konsisten
      const appName = process.env.SENDGRID_SENDER_NAME || 'SistemPakar SIBAYAM';
  
      // Coba buat transporter setiap kali untuk menghindari koneksi mati
      const transporter = createGmailTransporter();
      
      // Email sangat sederhana tetapi efektif
      const mailOptions = {
        from: `"${appName}" <${process.env.EMAIL_FROM}>`, // Menggunakan EMAIL_FROM dari .env
        to: email,
        subject: `[${code}] Kode Verifikasi ${appName}`, // Tanda kode di subject membantu visibilitas
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 5px;">
            <h2 style="color: #333; margin-bottom: 20px;">Reset Password</h2>
            <p>Halo ${user.name || 'Pengguna'},</p>
            <p style="color: #666; margin-bottom: 15px;">Anda telah meminta untuk mereset password akun SIBAYAM Anda.</p>
            <div style="background: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <p style="font-size: 16px; margin: 0;">Kode verifikasi Anda:</p>
                <h1 style="color: #4CAF50; margin: 10px 0; letter-spacing: 5px;">${code}</h1>
            </div>
            <p style="color: #666; margin-bottom: 15px;">Kode ini akan kadaluarsa dalam 10 menit.</p>
            <p style="color: #999; font-size: 12px; margin-top: 30px;">Jika Anda tidak meminta reset password, abaikan email ini.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;"/>
            <p style="color: #999; font-size: 12px;">Email ini dikirim oleh sistem SIBAYAM. Mohon jangan membalas email ini.</p>
        </div>
        `
      };
  
      // Tambahkan debugging
      console.log('Mengirim email ke:', email);
      console.log('Menggunakan akun:', process.env.EMAIL_FROM);
      console.log('Dengan transporter:', transporter ? 'Berhasil dibuat' : 'Gagal dibuat');
  
      // Kirim email dengan try-catch terpisah untuk debugging
      try {
        const info = await transporter.sendMail(mailOptions);
        console.log('Email reset password berhasil dikirim via Gmail:', info.messageId);
        console.log('Preview URL:', nodemailer.getTestMessageUrl(info));
  
        return res.json({
          message: 'Kode verifikasi telah dikirim ke email Anda.',
          expiresIn: '10 menit',
        });
      } catch (emailError) {
        console.error('Error saat mengirim email:', emailError);
        return res.status(500).json({
          message: 'Gagal mengirim kode verifikasi via email',
          error: process.env.NODE_ENV === 'development' ? emailError.toString() : undefined,
        });
      }
    } catch (error) {
      console.error('Error in sendResetCodeWithGmail:', error);
      return res.status(500).json({
        message: 'Gagal memproses permintaan reset password',
        error: process.env.NODE_ENV === 'development' ? error.toString() : undefined,
      });
    }
  };

sgMail.setApiKey(process.env.SENDGRID_API_KEY);  

exports.resetPasswordWithCode = async (req, res) => {
    const { code, password } = req.body;
    
    try {
        // Validasi input
        if (!code || !password) {
            return res.status(400).json({ 
                message: "Kode dan password baru wajib diisi" 
            });
        }

        // Validasi password yang lebih ketat
        if (password.length < 8) {
            return res.status(400).json({ 
                message: "Password harus minimal 8 karakter" 
            });
        }
    
        const user = await User.findOne({ 
            where: { 
                resetToken: code
            } 
        });
    
        if (!user) {
            return res.status(400).json({ 
                message: "Kode verifikasi salah" 
            });
        }

        // Check if code is expired
        const now = new Date();
        if (now > user.resetTokenExpiry) {
            return res.status(400).json({ 
                message: "Kode verifikasi sudah kadaluarsa. Silakan minta kode baru." 
            });
        }
    
        const hashedPassword = await argon2.hash(password);
    
        await user.update({
            password: hashedPassword,
            resetToken: null,
            resetTokenExpiry: null
        });
    
        // Kirim email konfirmasi menggunakan Gmail
        try {
            const appName = process.env.SENDGRID_SENDER_NAME || 'SistemPakar SIBAYAM';
            const transporter = createGmailTransporter();
            
            const mailOptions = {
                from: `"${appName}" <${process.env.EMAIL_FROM}>`,
                to: user.email,
                subject: `Password Berhasil Diubah - ${appName}`,
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 5px;">
                        <h2 style="color: #333; margin-bottom: 20px;">Password Berhasil Diubah</h2>
                        <p>Halo ${user.name || 'Pengguna'},</p>
                        <p style="color: #666; margin-bottom: 15px;">Password akun SIBAYAM Anda telah berhasil diubah.</p>
                        <div style="background: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
                            <p style="font-size: 16px; margin: 0; color: #4CAF50;">✓ Password telah diperbarui</p>
                        </div>
                        <p style="color: #666; margin-bottom: 15px;">Jika Anda tidak melakukan perubahan ini, segera hubungi tim dukungan kami.</p>
                        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;"/>
                        <p style="color: #999; font-size: 12px;">Email ini dikirim oleh sistem SIBAYAM. Mohon jangan membalas email ini.</p>
                    </div>
                `
            };

            // Tambahkan debugging
            console.log('Mengirim email konfirmasi ke:', user.email);
            console.log('Menggunakan akun:', process.env.EMAIL_FROM);

            const info = await transporter.sendMail(mailOptions);
            console.log('Email konfirmasi berhasil dikirim via Gmail:', info.messageId);
            console.log('Preview URL:', nodemailer.getTestMessageUrl(info));

        } catch (emailError) {
            console.error('Error saat mengirim email konfirmasi:', emailError);
            // Tidak menghentikan proses meski email konfirmasi gagal
        }
    
        return res.json({ 
            message: "Password berhasil direset",
            success: true
        });
    
    } catch (error) {
        console.error("Error in resetPasswordWithCode:", error);
        return res.status(500).json({ 
            message: "Terjadi kesalahan pada server",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};