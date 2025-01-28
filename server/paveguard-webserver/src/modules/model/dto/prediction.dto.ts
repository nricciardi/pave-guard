import { Field, ArgsType, ObjectType } from '@nestjs/graphql';
import { IsArray, IsBoolean, IsDate, IsNotEmpty, IsNumber, IsString, Max, Min } from 'class-validator';

@ArgsType()
@ObjectType()
export class PredictionDto {

    @Field()
    @IsDate()
    @IsNotEmpty()
    updatedAt: Date;

    @Field(type => [Number])
    @IsArray()
    @IsNotEmpty()
    crackSeverityPredictions: number[];

    @Field(type => [Number])
    @IsArray()
    @IsNotEmpty()
    potholeSeverityPredictions: number[];

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
