import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";

export class AjouterConcurentDto {

    @IsNotEmpty()
    @IsString()
    readonly nom: String;

    @IsNotEmpty()
    @IsString()
    readonly abreviation: String;

}