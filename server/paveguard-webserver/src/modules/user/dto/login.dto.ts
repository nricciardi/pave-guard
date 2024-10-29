import { Field, ArgsType } from '@nestjs/graphql';
import { IsString } from 'class-validator';

@ArgsType()
export class LoginDto {
  @Field()
  @IsString()
  email: string;

  @Field()
  @IsString()
  password: string;
}
