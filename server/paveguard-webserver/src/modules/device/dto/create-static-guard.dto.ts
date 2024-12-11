import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNotEmpty, IsNumber, IsString } from 'class-validator';

@ArgsType()
export class CreateStaticGuardDto {
  @Field()
  @IsString()
  @IsNotEmpty()
  serialNumber: string;

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

  @Field()
  @IsNumber()
  @IsNotEmpty()
  latitude: number;

  @Field()
  @IsNumber()
  @IsNotEmpty()
  longitude: number;
}
