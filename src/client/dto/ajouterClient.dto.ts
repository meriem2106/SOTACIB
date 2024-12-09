import { Type } from 'class-transformer';
import { IsNotEmpty, IsNumber, IsString, ValidateNested, IsArray, IsOptional } from 'class-validator';

export class AjouterClientDto {
  @IsNotEmpty()
  @IsString()
  readonly responsable: string;

  @IsNotEmpty()
  @IsString()
  readonly clientNom: string;

  @IsNotEmpty()
  @IsString()
  readonly clientType: 'G' | 'D' | 'NC';

  @IsNotEmpty()
  @IsString()
  readonly email: string;

  @IsNotEmpty()
  @IsNumber()
  readonly telephone: number;

  @IsNotEmpty()
  @IsString()
  readonly address: string;

  @IsNotEmpty()
  @IsString()
  readonly gouvernoratNom: string;

  @IsNotEmpty()
  @IsString()
  readonly delegationNom: string;

  @IsOptional() // Allow this field to be omitted
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ProduitConcurentPrixDto)
  produits?: ProduitConcurentPrixDto[]; // Mark it optional with '?'
}

class ProduitConcurentPrixDto {
  @IsNotEmpty()
  @IsString()
  readonly concurentId: string;

  @IsNotEmpty()
  @IsString()
  readonly produitId: string;

  @IsNotEmpty()
  @IsNumber()
  readonly prix: number;
}
