import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNumber, IsString } from 'class-validator';

@ArgsType()
export class CreateStaticGuardDto {
  @Field()
  @IsString()
  serialNumber: string;

  @Field()
  @IsString()
  road: string;

  @Field()
  @IsNumber()
  latitude: number;

  @Field()
  @IsNumber()
  longitude: number;
}
