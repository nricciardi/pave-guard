import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNotEmpty, IsNumber, IsString } from 'class-validator';

@ArgsType()
export class CreateDynamicGuardDto {
  @Field()
  @IsString()
  @IsNotEmpty()
  serialNumber: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  userId: string;
}
