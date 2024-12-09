import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { GouvernoratService } from './gouvernorat.service';
import { AjouterGouvernoratDto } from './dto/ajouterGouvernorat.dto';

@Controller('gouvernorat')
export class GouvernoratController {
  constructor(private readonly gouvernoratService: GouvernoratService) {}

  @Post('/ajouterGouvernorat')
  create(@Body() ajouterGouvernoratDto: AjouterGouvernoratDto): Promise<{ gouvernorat }> {
    return this.gouvernoratService.create(ajouterGouvernoratDto);
  }

  @Get('/fetchGouvernoart')
  findAll() {
    return this.gouvernoratService.findAll();
  }

}