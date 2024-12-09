import { IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class AjouterProduitDto {
  @IsNotEmpty()
  @IsString()
  nom: string;

  @IsNotEmpty()
  @IsNumber()
  prix: number;
}