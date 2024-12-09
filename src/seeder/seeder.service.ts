import { Injectable, OnModuleInit } from '@nestjs/common';
import { UserService } from '../user/user.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class SeederService implements OnModuleInit {
  constructor(private readonly userService: UserService) {
    console.log('SeederService: Initialized'); // Debug log
  }

  async onModuleInit() {
    console.log('SeederService: Running onModuleInit...'); // Debug log

    const adminEmail = 'Helmi@sotacib.com';
    const existingAdmin = await this.userService.findByEmail(adminEmail);

    if (!existingAdmin) {
      console.log('SeederService: Admin not found, creating...');
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await this.userService.createUser({
        name: 'Helmi',
        email: adminEmail,
        password: hashedPassword,
        role: 'admin',
      });
      console.log('SeederService: Admin created successfully!');
    } else {
      console.log('SeederService: Admin already exists.');
    }
  }
}