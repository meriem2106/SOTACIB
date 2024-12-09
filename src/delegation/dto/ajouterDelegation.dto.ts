import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";

export class AjouterDelegationDto {

    @IsNotEmpty()
    @IsString()
    readonly nom: String;

    @IsNotEmpty()
    @IsString()
    readonly gouvernoratNom: string;

} 