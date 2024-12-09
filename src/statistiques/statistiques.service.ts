import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Visite } from '../visite/schemas/visite.schema';
import { Produit } from '../produit/schema/produit.schema';
import { Client } from '../client/schema/client.schema';
import { Gouvernorat } from '../gouvernorat/schema/gouvernorat.schema';
import { Concurent } from '../concurent/schema/concurent.schema';

@Injectable()
export class StatistiquesService {
  constructor(
    @InjectModel(Visite.name) private readonly visiteModel: Model<Visite>,
    @InjectModel(Produit.name) private readonly produitModel: Model<Produit>,
    @InjectModel(Client.name) private readonly clientModel: Model<Client>,
    @InjectModel(Gouvernorat.name) private readonly gouvernoratModel: Model<Gouvernorat>,
    @InjectModel(Concurent.name) private readonly concurentModel: Model<Concurent>,
  ) {}

  async getPrixEvolution(filters: {
    gouvernoratId: string;
    concurentId: string;
    produitId: string;
  }) {
    const { gouvernoratId, concurentId, produitId } = filters;
  
    try {
      const visites = await this.visiteModel.aggregate([
        {
          $match: {
            'client.gouvernorat': new Types.ObjectId(gouvernoratId),
            'cimenteries.produits.produit': new Types.ObjectId(produitId),
          },
        },
        { $unwind: '$cimenteries' },
        { $unwind: '$cimenteries.produits' },
        {
          $match: {
            'cimenteries.cimenterie': new Types.ObjectId(concurentId),
            'cimenteries.produits.produit': new Types.ObjectId(produitId),
          },
        },
        {
          $group: {
            _id: {
              year: { $year: '$date' },
              month: { $month: '$date' },
            },
            avgPrice: { $avg: '$cimenteries.produits.prix' },
          },
        },
        { $sort: { '_id.year': 1, '_id.month': 1 } },
      ]);
  
      console.log('Aggregation result:', visites);
  
      // Format the response to include readable month names
      const formattedResponse = visites.map((v) => ({
        month: `${v._id.year}-${String(v._id.month).padStart(2, '0')}`,
        avgPrice: v.avgPrice,
      }));
  
      return {
        gouvernoratId,
        concurentId,
        produitId,
        prices: formattedResponse,
      };
    } catch (error) {
      console.error('Error during aggregation:', error);
      throw new InternalServerErrorException('Error calculating price evolution');
    }
  }

  async getProductAvailability(filters: {
    startDate: string;
    endDate: string;
    produitId: string;
  }) {
    const { startDate, endDate, produitId } = filters;
  
    try {
      // Parse dates
      const start = new Date(startDate);
      const end = new Date(endDate);
  
      if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        throw new Error('Invalid startDate or endDate');
      }
  
      // Aggregate data
      const results = await this.visiteModel.aggregate([
        {
          $match: {
            date: { $gte: start, $lte: end },
            'cimenteries.produits.produit': new Types.ObjectId(produitId),
          },
        },
        { $unwind: '$cimenteries' },
        { $unwind: '$cimenteries.produits' },
        {
          $group: {
            _id: {
              gouvernorat: '$client.gouvernorat',
              date: { $dateToString: { format: '%Y-%m-%d %H:00', date: '$date' } },
            },
            totalVisits: { $sum: 1 },
            totalAvailable: {
              $sum: {
                $cond: [
                  { $eq: ['$cimenteries.produits.produit', new Types.ObjectId(produitId)] },
                  1,
                  0,
                ],
              },
            },
          },
        },
        {
          $project: {
            gouvernorat: '$_id.gouvernorat',
            date: '$_id.date',
            availabilityPercentage: {
              $multiply: [{ $divide: ['$totalAvailable', '$totalVisits'] }, 100],
            },
          },
        },
        { $sort: { date: 1 } },
        {
          $group: {
            _id: '$date',
            highestAvailability: { $max: '$availabilityPercentage' },
            governorates: {
              $push: { gouvernorat: '$gouvernorat', availability: '$availabilityPercentage' },
            },
          },
        },
      ]);
  
      // Format the response
      const formattedResults = results.map((item) => ({
        date: item._id,
        highestAvailability: item.highestAvailability.toFixed(2),
        governorates: item.governorates.map((gov) => ({
          gouvernorat: gov.gouvernorat,
          availability: gov.availability.toFixed(2),
        })),
      }));
  
      // Create a summary table
      const summary = await this.visiteModel.aggregate([
        {
          $match: {
            date: { $gte: start, $lte: end },
            'cimenteries.produits.produit': new Types.ObjectId(produitId),
          },
        },
        { $unwind: '$cimenteries' },
        { $unwind: '$cimenteries.produits' },
        {
          $group: {
            _id: '$client.gouvernorat',
            totalVisits: { $sum: 1 },
            totalAvailable: {
              $sum: {
                $cond: [
                  { $eq: ['$cimenteries.produits.produit', new Types.ObjectId(produitId)] },
                  1,
                  0,
                ],
              },
            },
          },
        },
        {
          $lookup: {
            from: 'gouvernorats', // Replace with your governorates collection name
            localField: '_id',
            foreignField: '_id',
            as: 'gouvernoratDetails',
          },
        },
        {
          $project: {
            gouvernorat: { $arrayElemAt: ['$gouvernoratDetails.nom', 0] },
            availabilityPercentage: {
              $multiply: [{ $divide: ['$totalAvailable', '$totalVisits'] }, 100],
            },
          },
        },
      ]);
  
      return {
        trend: formattedResults,
        summary: summary.map((item) => ({
          gouvernorat: item.gouvernorat || 'Unknown',
          availabilityPercentage: item.availabilityPercentage.toFixed(2),
        })),
      };
    } catch (error) {
      if (error instanceof Error) {
        console.error('Error in getProductAvailability:', error.message);
      } else {
        console.error('Error in getProductAvailability:', error);
      }
      throw new InternalServerErrorException('Error calculating product availability');
    }
  }


  async getVisitAndSalesStats(filters: {
    startDate: string;
    endDate: string;
    gouvernoratId: string;
    commercialId: string;
  }) {
    const { startDate, endDate, gouvernoratId } = filters;

    try {
      // Parse dates
      const start = new Date(startDate);
      const end = new Date(endDate);

      if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        throw new Error('Invalid startDate or endDate');
      }

      // Aggregate data for line chart
      const lineChartData = await this.visiteModel.aggregate([
        {
          $match: {
            date: { $gte: start, $lte: end },
            'client.gouvernorat': new Types.ObjectId(gouvernoratId),
          },
        },
        {
          $group: {
            _id: {
              date: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
            },
            totalVisits: { $sum: 1 },
          },
        },
        {
          $project: {
            _id: 0,
            date: '$_id.date',
            totalVisits: 1,
          },
        },
        { $sort: { date: 1 } },
      ]);

      // Aggregate data for pie chart
      const pieChartData = await this.visiteModel.aggregate([
        {
          $match: {
            date: { $gte: start, $lte: end },
            'client.gouvernorat': new Types.ObjectId(gouvernoratId),
          },
        },
        {
          $group: {
            _id: '$commercial.name', // Group by commercial name
            totalSales: { $sum: '$sales' },
          },
        },
        {
          $group: {
            _id: null,
            totalSales: { $sum: '$totalSales' }, // Calculate total sales for all commercials
            commercials: {
              $push: { name: '$_id', sales: '$totalSales' },
            },
          },
        },
        { $unwind: '$commercials' },
        {
          $project: {
            _id: 0,
            commercial: '$commercials.name',
            salesPercentage: {
              $multiply: [
                { $divide: ['$commercials.sales', '$totalSales'] },
                100,
              ],
            },
          },
        },
      ]);

      return {
        lineChartData,
        pieChartData,
      };
    } catch (error) {
      console.error(
        'Error in getVisitAndSalesStats:',
        error instanceof Error ? error.message : error,
      );
      throw new InternalServerErrorException(
        'Error fetching visit and sales statistics',
      );
    }
  }



  async getSalesEvolution(filters: {
    startDate: string;
    endDate: string;
    gouvernoratId: string;
    delegationId: string;
    clientId: string;
    produitId: string;
  }) {
    const { startDate, endDate, gouvernoratId, delegationId, clientId, produitId } = filters;
  
    try {
      // Parse dates
      const start = new Date(startDate);
      const end = new Date(endDate);
  
      // Validate dates
      if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        throw new Error('Invalid startDate or endDate');
      }
  
      // Define the aggregation pipeline
      const salesData = await this.visiteModel.aggregate([
        {
          $match: {
            date: { $gte: start, $lte: end },
            'client.gouvernorat': new Types.ObjectId(gouvernoratId),
            'client.delegation': delegationId, // Assuming this is stored as a string
            'client.clientId': clientId,       // Assuming this is stored as a string
            'cimenteries.produits.produit': new Types.ObjectId(produitId),
          },
        },
        { $unwind: '$cimenteries' },
        { $unwind: '$cimenteries.produits' },
        {
          $group: {
            _id: {
              date: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
              produit: '$cimenteries.produits.produit',
            },
            totalSales: { $sum: '$cimenteries.produits.sales' }, // Using "sales" field for aggregation
          },
        },
        {
          $group: {
            _id: '$_id.date',
            salesByProduct: {
              $push: {
                produit: '$_id.produit',
                totalSales: '$totalSales',
              },
            },
          },
        },
        {
          $project: {
            _id: 0,
            date: '$_id',
            salesByProduct: 1,
          },
        },
        { $sort: { date: 1 } },
      ]);
  
      console.log('Sales Data:', salesData);
  
      return { salesData };
    } catch (error) {
      console.error(
        'Error in getSalesEvolution:',
        error instanceof Error ? error.message : error,
      );
      throw new InternalServerErrorException(
        'Error fetching sales evolution data',
      );
    }
  }
}