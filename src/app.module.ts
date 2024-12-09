import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { UserModule } from './user/user.module';
import { SeederService } from './seeder/seeder.service'; 
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { ConcurentModule } from './concurent/concurent.module';
import { VisiteModule } from './visite/visite.module';
import { ProduitModule } from './produit/produit.module';
import { ClientModule } from './client/client.module';
import { DelegationModule } from './delegation/delegation.module';
import { GouvernoratModule } from './gouvernorat/gouvernorat.module';
import { StatistiquesModule } from './statistiques/statistiques.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }), 
    MongooseModule.forRoot(process.env.MONGO_URI),
    AuthModule,
    UserModule,
    ConcurentModule,
    VisiteModule,
    ProduitModule,
    ClientModule,
    DelegationModule,
    GouvernoratModule,
    StatistiquesModule,
  ],
  providers: [AppService, SeederService], 
  controllers: [AppController],
})
export class AppModule {}