import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";

export class AjouterGouvernoratDto {

    @IsNotEmpty()
    @IsString()
    readonly nom: String;

}