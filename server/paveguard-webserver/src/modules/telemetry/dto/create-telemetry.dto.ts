import { Field, ArgsType, ObjectType, InputType } from '@nestjs/graphql';
import { Type } from 'class-transformer';
import { IsDate, IsNotEmpty, IsNumber, IsString, ValidateNested } from 'class-validator';


@ObjectType()
@InputType()
export class MetadataDto {
  @Field()
  @IsString()
  deviceId: string;
}

@ArgsType()
export class CreateTelemetryDto {
  
  @Field()
  @ValidateNested()
  metadata: MetadataDto;

  @Field()
  @IsDate()
  @IsNotEmpty()
  timestamp: Date;

  @Field()
  @IsNumber()
  @IsNotEmpty()
  latitude: number;

  @Field()
  @IsNumber()
  @IsNotEmpty()
  longitude: number;
}
