import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Device } from "./device.model";
import { Types } from "mongoose";


@Schema()
export class DynamicGuard extends Device {
    @Prop({ type: Types.ObjectId, ref: 'User', required: true })
    userId: Types.ObjectId;
}

export const DynamicGuardSchema = SchemaFactory.createForClass(DynamicGuard);