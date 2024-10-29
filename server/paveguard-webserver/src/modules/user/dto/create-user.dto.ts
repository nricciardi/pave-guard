import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsString } from 'class-validator';

@ArgsType()
export class CreateUserDto {
  @Field()
  @IsString()
  email: string;

  @Field()
  @IsString()
  password: string;

  @Field()
  @IsString()
  firstName: string;

  @Field()
  @IsString()
  lastName: string;

  @Field()
  @IsString()
  userCode: string;
}
