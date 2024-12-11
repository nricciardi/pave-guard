import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsLatitude, IsLongitude, IsMongoId, IsNotEmpty, IsString } from 'class-validator';


@ArgsType()
export class CreateDynamicTelemetryDto {
  
  @Field()
  @IsString()
  @IsMongoId()
  @IsNotEmpty()
  deviceId: string;

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

  @Field({
    description: "can be either timestamp or datetime"
  })
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
  @IsNotEmpty()
  deviceId: string;

  @Field()
  @IsDate()
  @IsNotEmpty()
  @IsNotEmpty()
  timestamp: string;
}



