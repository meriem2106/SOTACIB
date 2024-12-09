// src/auth/auth.service.ts
import { Injectable, NotFoundException,UnauthorizedException } from '@nestjs/common';
import { UserService } from '../user/user.service';
import * as nodemailer from 'nodemailer';
import retry from 'async-retry';
import * as bcrypt from 'bcrypt';




@Injectable()
export class AuthService {
  constructor(private readonly userService: UserService) {}

  async handleForgetPassword(email: string): Promise<{ message: string }> {
    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User with this email does not exist');
    }

    // Generate OTP (6-digit random number)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes expiry

    // Save OTP and expiry in the user's record
    await this.userService.saveOtp(user._id, otp, otpExpiry);

    // Send OTP via email
    await this.sendOtpEmail(email, otp);

    return { message: 'OTP sent to your email' };
  }

  private async sendOtpEmail(email: string, otp: string): Promise<void> {
    await retry(async () => {
        const transporter = nodemailer.createTransport({
            host: 'smtp.gmail.com',
            port: 465, // Use port 465
            secure: true, // Enable SSL
            auth: {
              user: process.env.SMTP_USER, // Your Gmail address
              pass: process.env.SMTP_PASS, // Your Gmail App Password
            },
          });
  
      const mailOptions = {
        from: process.env.SMTP_USER,
        to: email,
        subject: 'Password Reset OTP',
        text: `Your OTP for password reset is: ${otp}. It will expire in 5 minutes.`,
      };
  
      await transporter.sendMail(mailOptions);
    }, {
      retries: 3, // Retry 3 times
      minTimeout: 2000, // Wait 1 second between retries
    });
  }


  async verifyOtp(otp: string): Promise<{ message: string }> {
    // Assuming the user is authenticated, retrieve their information
    const user = await this.userService.findUserWithPendingOtp(); // Replace this with your logic to find the relevant user
  
    if (!user) {
      throw new UnauthorizedException('User not found or OTP expired');
    }
  
    // Validate OTP
    if (user.otp !== otp) {
      throw new UnauthorizedException('Invalid OTP');
    }
  
    // Check expiry
    if (user.otpExpiry && user.otpExpiry < new Date()) {
      throw new UnauthorizedException('OTP has expired');
    }
  
    // Clear the OTP and expiry
    await this.userService.clearOtp(user._id);
  
    return { message: 'OTP verified successfully' };
  }


  async resetPassword(userId: string, newPassword: string): Promise<void> {
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await this.userService.updatePassword(userId, hashedPassword);
  }

}