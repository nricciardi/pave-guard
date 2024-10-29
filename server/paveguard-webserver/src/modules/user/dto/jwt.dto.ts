import { Field, ArgsType } from '@nestjs/graphql';
import { IsString } from 'class-validator';

@ArgsType()
export class JwtDto {

    @Field()
    @IsString()
    userId: string;

    @Field()
    @IsString()
    email: string;
}
