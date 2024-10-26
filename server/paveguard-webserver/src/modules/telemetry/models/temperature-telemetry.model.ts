import { Field, ID, ObjectType } from '@nestjs/graphql';
import { ITelemetryQuery, ITelemetrySchema, Telemetry } from './telemetry.model';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';


@ObjectType()
export class TemperatureTelemetryQuery implements ITelemetryQuery {

  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: number;

  @Field()
  temperature: number;
}


@Schema()
export class TemperatureTelemetry implements ITelemetrySchema {
  deviceId: string;
  timestamp: number;
  kind: string;

  @Prop({ required: true })
  temperature: number;
}

export const TemperatureTelemetrySchema = SchemaFactory.createForClass(TemperatureTelemetry);
