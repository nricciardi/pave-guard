import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNumber, IsString } from 'class-validator';

@ArgsType()
export class CreateDynamicGuardDto {
  @Field()
  @IsString()
  serialNumber: string;

  @Field()
  @IsString()
  userId: string;
}
