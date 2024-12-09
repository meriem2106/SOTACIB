import { Controller, Post, Req,Body,UseGuards, UnauthorizedException,NotFoundException ,BadRequestException} from '@nestjs/common';
import { UserService } from '../user/user.service';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from '../guard/jwt-auth.guard';



@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
    private readonly configService: ConfigService, // Access .env variables
  ) {}

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const user = await this.userService.findByEmail(body.email);

    if (!user || !(await bcrypt.compare(body.password, user.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const accessToken = jwt.sign(
      { id: user._id, email: user.email, role: user.role }, // Add email to the payload
      this.configService.get<string>('JWT_SECRET'), // Access secret
      { expiresIn: this.configService.get<string>('JWT_EXPIRATION') }, // Expiration time
    );

    const refreshToken = jwt.sign(
      { id: user._id },
      this.configService.get<string>('REFRESH_TOKEN_SECRET'), // Refresh token secret
      { expiresIn: this.configService.get<string>('REFRESH_TOKEN_EXPIRATION') }, // Expiration time
    );

    return { accessToken, refreshToken }; // Send tokens to the client
  }

  @Post('forget-password')
  async forgetPassword(@Body() body: { email: string }) {
    const email = body.email;
    if (!email) {
      throw new NotFoundException('Email is required');
    }

    return this.authService.handleForgetPassword(email);
  }

  @Post('verify-otp')
  async verifyOtp(@Body() body: { otp: string }) {
    const { otp } = body;
  
    if (!otp) {
      throw new BadRequestException('OTP is required');
    }
  
    // Call the service to verify the OTP
    return this.authService.verifyOtp(otp);
  }


 
  @Post('reset-password')
  @UseGuards(JwtAuthGuard)
  async resetPassword(
    @Req() req: any, // Access request object
    @Body() body: { newPassword: string; confirmPassword: string },
  ) {
    const { newPassword, confirmPassword } = body;

    if (!newPassword || !confirmPassword) {
      throw new BadRequestException('Both newPassword and confirmPassword are required');
    }

    if (newPassword !== confirmPassword) {
      throw new BadRequestException('Passwords do not match');
    }

    const userId = req.user?.id; // Extract the userId from the authenticated user
    if (!userId) {
      throw new UnauthorizedException('Unauthorized');
    }

    await this.authService.resetPassword(userId, newPassword);
    return { message: 'Password reset successfully' };
  }
}