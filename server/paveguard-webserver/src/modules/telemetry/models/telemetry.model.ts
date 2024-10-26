import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { TemperatureTelemetry } from './temperature-telemetry.model';
import { Field, ID, ObjectType } from '@nestjs/graphql';
import { HumidityTelemetry } from './humidity-telemetry.model';


interface ITelemetry {
  deviceId: string;
  timestamp: number;
}

export interface ITelemetryQuery extends ITelemetry {
  id: string;
}

export interface ITelemetrySchema extends ITelemetry {
  kind: string;
}


@ObjectType()
export class TelemetryQuery implements ITelemetryQuery {
  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: number;
}

@Schema({ discriminatorKey: 'kind' })
export class Telemetry {

  @Prop({ required: true })
  deviceId: string;

  @Prop({ required: true })
  timestamp: number;

  @Prop({
    type: String,
    required: true,
    enum: [
      TemperatureTelemetry.name,
      HumidityTelemetry.name
    ]
  })
  kind: string;
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);
