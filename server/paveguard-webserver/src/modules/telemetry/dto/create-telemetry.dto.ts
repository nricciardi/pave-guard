import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsLatitude, IsLongitude, IsMongoId, IsNotEmpty, IsString } from 'class-validator';


@ArgsType()
export class CreateDynamicTelemetryDto {
  
  @Field()
  @IsString()
  @IsMongoId()
  deviceId: string;

  @Field()
  @IsString()
  road: string;

  @Field()
  @IsString()
  city: string;

  @Field()
  @IsString()
  county: string;

  @Field()
  @IsString()
  state: string;

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


@ArgsType()
export class CreateStaticTelemetryDto {
  
  @Field()
  @IsString()
  @IsMongoId()
  deviceId: string;

  @Field()
  @IsDate()
  @IsNotEmpty()
  timestamp: string;
}



