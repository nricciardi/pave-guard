import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNumber, IsString } from 'class-validator';

@ArgsType()
export class CreateStaticGuardDto {
  @Field()
  @IsString()
  serialNumber: string;

  @Field()
  @IsString()
  street: string;

  @Field()
  @IsNumber()
  latitude: number;

  @Field()
  @IsNumber()
  longitude: number;
}
