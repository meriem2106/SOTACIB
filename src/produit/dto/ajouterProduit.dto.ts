import { IsNotEmpty, IsString, IsNumber } from 'class-validator';

export class AjouterProduitDto {
  @IsNotEmpty()
  @IsString()
  readonly nom: string;

  @IsNotEmpty()
  @IsNumber()
  readonly prix: number;

  @IsNotEmpty()
  @IsString()
  readonly concurentId: string; // Reference to Concurent
}