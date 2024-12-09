import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsArray,
  IsDate,
  IsMongoId,
} from 'class-validator';

export class AjouterVisiteDto {
  @IsNotEmpty()
  @IsDate()
  date: Date;

  @IsOptional()
  @IsString()
  observation?: string;

  @IsOptional()
  @IsString()
  reclamation?: string;

  @IsNotEmpty()
  @IsString()
  responsable: string;

  @IsArray()
  cimenteries: Array<{
    cimenterie: string; 
    produits: Array<{ produit: string; prix: number }>; 
  }>;

  @IsOptional()
  @IsMongoId()
  client?: string; 

  @IsOptional()
  @IsString()
  pieceJoint?: string;
}