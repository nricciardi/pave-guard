import { Field, ArgsType, ObjectType, InputType } from '@nestjs/graphql';
import { Type } from 'class-transformer';
import { IsDate, IsLatitude, IsLongitude, IsMongoId, IsNotEmpty, IsNumber, IsString, ValidateNested } from 'class-validator';


@ObjectType()
@InputType()
export class MetadataDto {
  @Field()
  @IsString()
  @IsMongoId()
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
  timestamp: string;

  @Field()
  @IsLatitude()
  @IsNotEmpty()
  latitude: number;

  @Field()
  @IsLongitude()
  @IsNotEmpty()
  longitude: number;
}
