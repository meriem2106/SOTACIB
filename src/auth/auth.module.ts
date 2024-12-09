import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from '../user/user.module'; // Import UserModule to use UserService


@Module({
  imports: [UserModule], // Import UserModule to provide UserService
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService], // Export AuthService if used elsewhere
})
export class AuthModule {}