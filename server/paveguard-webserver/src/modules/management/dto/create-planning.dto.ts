import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNotEmpty, IsNumber, IsString, Max, Min } from 'class-validator';

@ArgsType()
export class CreatePlanningDto {

    @Field()
    @IsDate()
    @IsNotEmpty()
    date: Date;

    @Field({
        nullable: true
    })
    @IsString()
    description?: string;

    @Field()
    @IsString()
    @IsNotEmpty()
    road: string;

    @Field()
    @IsString()
    @IsNotEmpty()
    city: string;

    @Field({
        nullable: true
    })
    @IsString()
    county?: string;

    @Field()
    @IsString()
    @IsNotEmpty()
    state: string;
}
