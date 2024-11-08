import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsNumber, IsString } from 'class-validator';

@ArgsType()
export class CreateTelemetryDto {
  @Field()
  @IsString()
  deviceId: string;

  @Field()
  @IsDate()
  timestamp: Date;

  @Field()
  @IsNumber()
  latitude: number;

  @Field()
  @IsNumber()
  longitude: number;
}
