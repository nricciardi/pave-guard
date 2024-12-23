import { Field, ArgsType, ObjectType } from '@nestjs/graphql';
import { IsNotEmpty, IsString } from 'class-validator';

@ObjectType()
@ArgsType()
export class LocationDto {
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