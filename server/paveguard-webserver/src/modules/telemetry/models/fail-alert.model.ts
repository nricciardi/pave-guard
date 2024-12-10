import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';


@Schema({ 
  timeseries: {
    timeField: "timestamp",
    granularity: "seconds",
    metaField: "metadata"
  } 
})
export class FailAlert extends Document {

  @Prop({
    required: true,
    type: {
      deviceId: { type: Types.ObjectId, ref: 'Device', required: true },
    }
  })
  metadata: {
    deviceId: Types.ObjectId;
  };

  @Prop({ required: true })
  timestamp: Date;

  @Prop({ required: true })
  code: string;

  @Prop({ required: false })
  message: string;
}

export const FailAlertSchema = SchemaFactory.createForClass(FailAlert);
